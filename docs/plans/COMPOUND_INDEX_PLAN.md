# Compound Index Implementation Plan

> **⚠️ BLOCKED: Requires streaming index reads to be implemented first**
>
> **Reason:** Current indices are fully loaded into memory, which defeats the purpose for large datasets. Compound indices would make this worse by increasing the number and size of index files.
>
> **Prerequisite:** Complete `STREAMING_INDEX_PLAN.md` implementation first.

## Overview
Implement compound indices to optimize multi-field equality queries by creating single indices that combine multiple fields, eliminating the need to intersect results from separate indices.

## Problem
Currently, multi-field queries like `.filter("name", "Alice").filter("age", 25)`:
1. Load `name` index → get IDs
2. Load `age` index → get IDs  
3. Intersect results

This is inefficient compared to a compound index that directly returns IDs for `name="Alice" AND age=25`.

## Proposed Solution

### 1. Index Naming Convention

**File names:** Use `_` to join field names (safe for file systems)
**File contents:** Use `&` to join values, `:` for value-to-ID mapping

Examples:
- Single field file: `name` → stores `Alice:123`
- Compound file: `age_name` → stores `25&Alice:123`
- Always alphabetically sorted: `name_age` (not `age_name`)

**Delimiter usage:**
- `_` for file names (e.g., `age_name`)
- `&` for joining compound values (e.g., `25&Alice`)
- `:` for value-to-ID mapping (e.g., `25&Alice:123`)

### 2. When to Create Compound Indices

Create compound index when:
- Query has 2+ equality filters
- Compound index doesn't already exist
- All fields are indexable (not List/Map)

**Strategy:** Create on-demand like single-field indices.

### 3. QueryEngine Changes

**File:** `lib/src/storage/impl/query_engine.dart`

**In `query` method:**
```dart
String? compoundIndexName = _getCompoundIndexName(query.allFilters!);

if (compoundIndexName != null) {
  await _ensureIndex(query.dataClass!, compoundIndexName, isCompound: true);
  
  IndexScanner<String> scanner = await IndexHelper.createScanner<T, String>(
    storage: store,
    type: query.dataClass!,
    colName: compoundIndexName,
  );
  
  String compoundValue = _buildCompoundValue(query.allFilters!);
  
  Set<int> filterIds = <int>{};
  await for (String point in scanner.scan()) {
    Pair<String, int> pair = Pair.fromString<String, int>(point);
    if (pair.key == compoundValue) {
      filterIds.add(pair.value);
    } else if (pair.key.compareTo(compoundValue) > 0) {
      break;
    }
  }
  
  candidateIds = filterIds;
} else {
  // Fall back to individual indices
}
```

**New method `_getCompoundIndexName`:**
```dart
String? _getCompoundIndexName(List<Filter> filters) {
  List<String> eqFields = [];
  for (var filter in filters) {
    if (filter.operation == FilterOperation.Equals) {
      eqFields.add(filter.fieldName);
    }
  }
  if (eqFields.length < 2) return null;
  eqFields.sort();
  return eqFields.join('_');
}
```

**New method `_buildCompoundValue`:**
```dart
String _buildCompoundValue(List<Filter> filters) {
  List<String> parts = [];
  List<Filter> eqFilters = filters
      .where((f) => f.operation == FilterOperation.Equals)
      .toList();
  eqFilters.sort((a, b) => a.fieldName.compareTo(b.fieldName));
  
  for (var filter in eqFilters) {
    var value = filter.value;
    if (value is DataType) {
      value = value.id;
    }
    parts.add('$value');
  }
  return parts.join('&');
}
```

### 4. WriteEngine Changes

**File:** `lib/src/storage/impl/write_engine.dart`

**In `_updateIndices`:**
```dart
for (FileSystemEntity file in files) {
  if (file is File) {
    String name = path.basename(file.path);
    
    bool isCompound = name.contains('_') && !RegExp(r'_\d+$').hasMatch(name);
    
    if (isCompound) {
      List<String> fieldNames = name.split('_');
      
      Index<String>? index = await IndexHelper.loadIndex<T, String>(
        storage: store,
        type: type,
        colName: name,
      );
      
      if (index != null) {
        for (T entity in entities) {
          List<String> values = [];
          bool skip = false;
          
          for (String fieldName in fieldNames) {
            var value = entity.toJson()[fieldName];
            if (value is Map && value.containsKey('id')) {
              value = value['id'];
            }
            if (value is List || value is Map) {
              skip = true;
              break;
            }
            values.add('$value');
          }
          
          if (!skip) {
            String point = '${values.join('&')}:${entity.id}';
            if (add) {
              if (!index.points!.contains(point)) {
                index.points!.add(point);
                modified = true;
              }
            } else {
              if (index.points!.remove(point)) {
                modified = true;
              }
            }
          }
        }
        
        if (modified) {
          await IndexHelper.saveIndex(
            storage: store,
            index: index,
            type: type,
            colName: name,
          );
        }
      }
    }
  }
}
```

### 5. _ensureIndex Changes

**Update `_ensureIndex` to support compound indices:**
```dart
Future<void> _ensureIndex<T extends DataType>(
  Class<T> type,
  String indexName, {
  bool isCompound = false,
  bool descending = false,
}) async {
  Directory indexFolder = Directory(
      "${(await store.ensureFolder(type.simpleName)).path}/.index/");
  File indexFile = File("${indexFolder.path}/$indexName");
  
  if (!await indexFile.exists()) {
    Index<String> index = Index<String>(indexName);
    index.points = <String>[];
    
    Directory folder = await store.ensureFolder(type.simpleName);
    Stream<FileSystemEntity> records = Directory("${folder.path}").list();
    
    bool indexable = true;
    await for (FileSystemEntity record in records) {
      if (record is File && record.path.endsWith(".json")) {
        String content = await record.readAsString();
        T entity = type.instance()..fromString(content);
        
        if (entity.id != null) {
          String? point;
          
          if (isCompound) {
            List<String> fieldNames = indexName.split('_');
            List<String> values = [];
            
            for (String fieldName in fieldNames) {
              var value = entity.toJson()[fieldName];
              if (value is Map && value.containsKey('id')) {
                value = value['id'];
              }
              if (value is List || value is Map) {
                indexable = false;
                break;
              }
              values.add('$value');
            }
            
            if (indexable && values.isNotEmpty) {
              point = '${values.join('&')}:${entity.id}';
            }
          } else {
            if (indexName == Key.indexName) {
              point = entity.id.toString();
            } else {
              var value = entity.toJson()[indexName];
              if (value is Map && value.containsKey('id')) {
                value = value['id'];
              }
              if (value is List || value is Map) {
                indexable = false;
                break;
              }
              if (value != null) {
                point = '$value:${entity.id}';
              }
            }
          }
          
          if (point != null) {
            index.points!.add(point);
          }
        }
      }
    }
    
    if (indexable) {
      if (descending) {
        index.points!.sort((a, b) => b.compareTo(a));
      } else {
        index.points!.sort();
      }
      
      await IndexHelper.saveIndex(
        storage: store,
        index: index,
        type: type,
        colName: indexName,
      );
    }
  }
}
```

## Example Usage

Query: `storage.load.user.filter("name", "Alice").filter("age", 25)`

**First execution:**
1. Detect 2 equality filters → compound index file `age_name` (sorted)
2. Index file doesn't exist → create it
3. Scan all users, build entries: `25&Alice:1`, `30&Bob:2`, etc.
4. Save to `age_name` file with gaps
5. Use it to find matching IDs

**Subsequent executions:**
1. Detect 2 equality filters → compound index file `age_name`
2. Index file exists → stream it
3. Find matching entry `25&Alice` → get IDs directly
4. Skip individual indices (more efficient)

## Benefits

- **Performance:** Single index lookup vs. multiple + intersection
- **Scalability:** Better for queries with many records
- **Automatic:** No configuration needed, created on-demand
- **Memory Efficient:** Works with streaming reads

## Considerations

- **Storage:** Compound indices require more disk space
- **Maintenance:** More indices to update on save/delete
- **Selectivity:** Only beneficial for selective queries
- **Detection:** Need logic to distinguish compound indices from tree children (both use `_`)

## Testing Plan

1. **Unit Tests:**
   - Compound index name generation
   - Compound value building
   - Index creation for 2, 3, 4+ fields

2. **Integration Tests:**
   - Multi-field equality queries
   - Index maintenance on save/delete
   - Performance vs. individual indices

3. **Edge Cases:**
   - Field names containing `_`
   - Null values in compound fields
   - Complex types (List/Map) - should skip

## Success Metrics

- Query performance improvement for multi-field queries
- Reduced memory usage vs. intersecting individual indices
- Predictable behavior with streaming reads

## Implementation Order

1. ✅ Implement streaming index reads (prerequisite)
2. Add compound index detection in QueryEngine
3. Implement compound key building
4. Update _ensureIndex for compound indices
5. Update WriteEngine for compound index maintenance
6. Add tests
7. Document usage and performance characteristics
