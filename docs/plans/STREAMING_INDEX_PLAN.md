# Streaming Index Reads Implementation Plan

## Overview
Implement forward-only streaming reads for index files to avoid loading entire indices into memory, enabling efficient queries on large datasets.

## Current Problem
`IndexHelper.loadIndex` loads entire index files into memory (`lines.map().toList()`), which:
- Defeats the purpose of indices for large datasets
- Causes O(n) memory usage
- Prevents early termination optimizations

## Prerequisites
- Current indexing system is functional
- Indices are sorted and stored as text files

## Implementation Steps

### 1. Create IndexScanner Class
**File:** `lib/src/storage/impl/index/index_scanner.dart`

```dart
class IndexScanner<T> {
  final File indexFile;
  final List<File> childFiles;
  
  IndexScanner(this.indexFile, this.childFiles);
  
  Stream<T> scan() async* {
    await for (String line in indexFile.openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())) {
      if (line.trim().isEmpty) continue;
      yield _parseLine<T>(line);
    }
    
    for (File child in childFiles) {
      await for (String line in child.openRead()
          .transform(utf8.decoder)
          .transform(LineSplitter())) {
        if (line.trim().isEmpty) continue;
        yield _parseLine<T>(line);
      }
    }
  }
  
  T _parseLine<T>(String line) {
    if (T == String) return line as T;
    if (T == int) return int.parse(line) as T;
    if (T == Pair<String, int>) return Pair.fromString<String, int>(line) as T;
    throw UnsupportedError('Type $T not supported');
  }
}
```

### 2. Update IndexHelper
**File:** `lib/src/storage/impl/helper/index_helper.dart`

Add new method:
```dart
static Future<IndexScanner<I>> createScanner<T, I>({
  required StorageImpl<Storage> storage,
  required Class<T> type,
  required String colName,
}) async {
  Directory indexFolder = Directory(
      "${(await storage.ensureFolder(type.simpleName)).path}/.index/");
  File indexFile = File("${indexFolder.path}/$colName");
  
  if (!await indexFile.exists()) {
    throw StateError('Index $colName does not exist');
  }
  
  List<File> childFiles = [];
  await for (FileSystemEntity entity in indexFolder.list()) {
    if (entity is File) {
      String name = path.basename(entity.path);
      if (name.startsWith('${colName}_') && RegExp(r'_\d+$').hasMatch(name)) {
        childFiles.add(entity);
      }
    }
  }
  
  childFiles.sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));
  
  return IndexScanner<I>(indexFile, childFiles);
}
```

**Keep `loadIndex` for write operations** - still needed to modify indices.

### 3. Update QueryEngine
**File:** `lib/src/storage/impl/query_engine.dart`

Replace index loading in `query` method:
```dart
IndexScanner<String> scanner = await IndexHelper.createScanner<T, String>(
  storage: store,
  type: query.dataClass!,
  colName: indexName,
);

Set<int> filterIds = <int>{};
await for (String point in scanner.scan()) {
  if (indexName == Key.indexName) {
    int id = int.parse(point);
    if (_matchesFilter(id, filter.value, filter.operation)) {
      filterIds.add(id);
    }
  } else {
    Pair<String, int> pair = Pair.fromString<String, int>(point);
    dynamic fVal = filter.value;
    if (fVal is DataType) {
      fVal = fVal.id;
    } else if (fVal is Iterable) {
      fVal = fVal.map((e) => e is DataType ? e.id : e).toList();
    }
    
    if (_matchesFilter(pair.key, fVal, filter.operation)) {
      filterIds.add(pair.value);
    }
  }
}
```

### 4. Sort Direction Support

**Option 1: Bidirectional Indices (Recommended)**
- Index naming: `name_asc`, `name_desc`
- Created on first use based on query direction
- Optimizes both directions

**Implementation in QueryEngine:**
```dart
String getIndexName(String fieldName, bool descending) {
  String baseName = fieldName == "id" ? Key.indexName : fieldName;
  return descending ? "${baseName}_desc" : "${baseName}_asc";
}
```

**Implementation in _ensureIndex:**
```dart
Future<void> _ensureIndex<T extends DataType>(
  Class<T> type, 
  String fieldName,
  bool descending,
) async {
  String indexName = getIndexName(fieldName, descending);
  
  if (descending) {
    index.points!.sort((a, b) => b.compareTo(a));
  } else {
    index.points!.sort();
  }
}
```

### 5. Gap Management for Insert Performance

**File Format with Gaps:**
```
10&Alice:1
<blank>
<blank>
15&Bob:2
<blank>
20&Charlie:3
<blank>
<blank>
```

**Update WriteEngine._updateIndices:**
```dart
Future<void> _insertIntoIndex(Index<String> index, String point) async {
  int insertPos = _findInsertPosition(index.points!, point);
  
  if (insertPos < index.points!.length && index.points![insertPos].isEmpty) {
    index.points![insertPos] = point;
  } else {
    index.points!.add(point);
    _markIndexDirty(indexName);
  }
}

int _findInsertPosition(List<String> points, String point) {
  int low = 0, high = points.length;
  while (low < high) {
    int mid = (low + high) ~/ 2;
    if (points[mid].isEmpty || points[mid].compareTo(point) < 0) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }
  return low;
}
```

**Compact Process:**
```dart
Future<void> compactIndex<T>(Class<T> type, String indexName) async {
  Index<String>? index = await IndexHelper.loadIndex<T, String>(
    storage: this,
    type: type,
    colName: indexName,
  );
  
  if (index == null) return;
  
  List<String> entries = index.points!.where((p) => p.isNotEmpty).toList();
  entries.sort();
  
  double gapRatio = 0.5;
  int totalSlots = (entries.length / (1 - gapRatio)).ceil();
  int gapSize = (totalSlots - entries.length) ~/ (entries.length + 1);
  
  List<String> newPoints = [];
  for (int i = 0; i < entries.length; i++) {
    newPoints.add(entries[i]);
    for (int j = 0; j < gapSize && newPoints.length < totalSlots; j++) {
      newPoints.add('');
    }
  }
  
  index.points = newPoints;
  await IndexHelper.saveIndex(
    storage: this,
    index: index,
    type: type,
    colName: indexName,
  );
}
```

## Testing Plan

1. **Unit Tests:**
   - IndexScanner streaming behavior
   - Gap insertion logic
   - Sort direction handling
   - Compact process correctness

2. **Integration Tests:**
   - Large dataset queries (10k+ records)
   - Memory usage validation
   - Insert performance with gaps
   - Bidirectional query performance

3. **Performance Tests:**
   - Compare memory: streaming vs loading
   - Compare speed: early termination vs full scan
   - Insert performance with/without gaps

## Migration Strategy

1. Implement `IndexScanner` class
2. Add `createScanner` to `IndexHelper`
3. Update `QueryEngine` to use scanner (keep fallback to `loadIndex`)
4. Add sort direction support
5. Implement gap management
6. Add compact command
7. Test thoroughly
8. Document performance characteristics

## Success Metrics

- Memory usage: O(1) instead of O(n) for index reads
- Query speed: Can stop early for selective queries
- Insert speed: O(1) amortized with gaps
- Predictable performance after compaction

## Next Steps After This

Once streaming reads are stable:
1. Implement compound indices
2. Add index statistics/metrics
3. Optimize gap ratio based on write patterns
