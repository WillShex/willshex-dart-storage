//
//  QueryEngine.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/src/storage/impl/filter.dart';
import 'package:willshex_storage/src/storage/impl/helper/index_helper.dart';
import 'package:willshex_storage/src/storage/impl/helper/query_helper.dart';
import 'package:willshex_storage/src/storage/impl/index/index.dart';
import 'package:willshex_storage/src/storage/impl/index/key.dart';
import 'package:willshex_storage/src/storage/impl/index/pair.dart';
import 'package:willshex_storage/src/storage/impl/loader_impl.dart';
import 'package:willshex_storage/src/storage/impl/order.dart';
import 'package:willshex_storage/src/storage/impl/query_impl.dart';
import 'package:willshex_storage/src/storage/impl/storage_impl.dart';
import 'package:willshex_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
@internal
class QueryEngine {
  Logger _log = Logger("QueryEngine");

  static const List<Order> DEFAULT_ORDER = const <Order>[
    const Order("id", SortDirectionType.ascending)
  ];

  LoaderImpl<Loader> loader;
  StorageImpl<Storage> store;

  QueryEngine(this.loader, this.store);

  Future<List<int>> queryIds<T extends DataType>(QueryImpl<T> q) async {
    List<T> entities = await query(q);
    List<int> ids = entities.map((e) => e.id!).toList();

    return ids;
  }

  Future<List<T>> query<T extends DataType>(QueryImpl<T> query) async {
    if (query.dataClass == null)
      throw AssertionError("Cannot query without a type");

    Set<int>? candidateIds;

    if (query.allFilters != null && query.allFilters!.isNotEmpty) {
      for (var filter in query.allFilters!) {
        String indexName = filter.fieldName;
        if (indexName == "id") indexName = Key.indexName;

        await _ensureIndex(query.dataClass!, indexName);
        Index<String>? index = await IndexHelper.loadIndex<T, String>(
          storage: store,
          type: query.dataClass!,
          colName: indexName,
        );

        if (index != null && index.points != null) {
          Set<int> filterIds = <int>{};
          for (String point in index.points!) {
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

              bool match = _matchesFilter(pair.key, fVal, filter.operation);
              if (match) {
                filterIds.add(pair.value);
              }
            }
          }

          if (candidateIds == null) {
            candidateIds = filterIds;
          } else {
            candidateIds = candidateIds.intersection(filterIds);
          }
        }
      }
    }

    List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

    if (candidateIds != null) {
      Map<int, T> loaded =
          await loader.createLoadEngine().load(query.dataClass!, candidateIds);
      for (T entity in loaded.values) {
        objects.add(entity.toJson());
      }
    } else {
      Directory folder = await store.ensureFolder(query.dataClass!.simpleName);
      Stream<FileSystemEntity> records = Directory("${folder.path}").list();

      int matchedCount = 0;
      bool canTerminateEarly =
          (query.allGroups == null || query.allGroups!.isEmpty) &&
              !query.isDistinct &&
              (query.allOrders == null || query.allOrders!.isEmpty);

      await for (FileSystemEntity record in records) {
        Map<String, dynamic> object;

        if (record is File && record.path.endsWith(".json")) {
          if (store.useCache) {
            String name = basenameWithoutExtension(record.path);
            int? possibleId = int.tryParse(name);

            if (possibleId != null) {
              T? found = store.ensureCacheType<T>(query.dataClass!)[possibleId];

              if (found != null) object = found.toJson();
            }
          }

          object = jsonDecode(await record.readAsString());

          if (QueryHelper.isMatchAll(object, query.allFilters)) {
            if (canTerminateEarly && matchedCount >= query.startAt) {
              objects.add(object);

              if (query.stopAfter > 0 && objects.length >= query.stopAfter) {
                break;
              }
            } else {
              objects.add(object);
            }

            matchedCount++;
          }
        }
      }
      _log.fine("Matched count ${query.dataClass?.name}: $matchedCount");
    }

    if (query.allGroups?.isNotEmpty ?? false) {
      final groupedObjects = <String, Map<String, dynamic>>{};

      for (final object in objects) {
        final keyParts = <String>[];

        for (final field in query.allGroups!) {
          keyParts.add(object[field]?.toString() ?? 'null');
        }

        final groupKey = keyParts.join('-');

        if (!groupedObjects.containsKey(groupKey)) {
          groupedObjects[groupKey] = object;
        }
      }

      objects = groupedObjects.values.toList();
    } else if (query.isDistinct) {
      final distinctKeys = <String>{};

      final distinctObjects = <Map<String, dynamic>>[];
      for (final object in objects) {
        final objectForDistinct = Map<String, dynamic>.from(object);

        objectForDistinct.remove("id");

        final key = jsonEncode(objectForDistinct);

        if (distinctKeys.add(key)) {
          distinctObjects.add(object);
        }
      }

      objects = distinctObjects;
    }

    QueryHelper.sort(
        objects, query.allOrders == null ? DEFAULT_ORDER : query.allOrders);

    if (query.startAt != 0) {
      if (query.startAt < objects.length) {
        objects = objects.sublist(query.startAt);
      } else {
        objects = <Map<String, dynamic>>[];
      }
    }

    int end;
    if ((end = query.stopAfter) < objects.length) {
      objects = objects.sublist(0, end);
    }

    if (query.isReverse) {
      objects = objects.reversed.toList();
    }

    List<T> matched = <T>[];

    if (query.isIdsOnly) {
      matched.addAll(objects.map((Map<String, dynamic> f) {
        return query.dataClass!.instance()..id = f["id"];
      }));
    } else {
      Map<int, T> loaded = await loader.createLoadEngine().load(
          query.dataClass!, objects.map((Map<String, dynamic> f) => f["id"]));

      for (Map<String, dynamic> object in objects) {
        if (loaded.containsKey(object["id"])) {
          matched.add(loaded[object["id"]]!);
        }
      }
    }

    return matched;
  }

  bool _matchesFilter(dynamic value, dynamic filterValue, FilterOperation op) {
    if (op == FilterOperation.In) {
      if (filterValue is Iterable) {
        for (var item in filterValue) {
          if (_matchesFilter(value, item, FilterOperation.Equals)) {
            return true;
          }
        }
        return false;
      }
      return false;
    }

    if (value is num && filterValue is num) {
      switch (op) {
        case FilterOperation.Equals:
          return value == filterValue;
        case FilterOperation.NotEquals:
          return value != filterValue;
        case FilterOperation.GreaterThan:
          return value > filterValue;
        case FilterOperation.GreaterThanOrEqual:
          return value >= filterValue;
        case FilterOperation.LessThan:
          return value < filterValue;
        case FilterOperation.LessThanOrEqual:
          return value <= filterValue;
        default:
          return false;
      }
    } else {
      String s1 = value.toString();
      String s2 = filterValue.toString();
      int cmp = s1.compareTo(s2);
      switch (op) {
        case FilterOperation.Equals:
          return s1 == s2;
        case FilterOperation.NotEquals:
          return s1 != s2;
        case FilterOperation.GreaterThan:
          return cmp > 0;
        case FilterOperation.GreaterThanOrEqual:
          return cmp >= 0;
        case FilterOperation.LessThan:
          return cmp < 0;
        case FilterOperation.LessThanOrEqual:
          return cmp <= 0;
        default:
          return false;
      }
    }
  }

  Future<void> _ensureIndex<T extends DataType>(
      Class<T> type, String indexName) async {
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
            if (indexName == Key.indexName) {
              point = entity.id.toString();
            } else {
              var value = entity.toJson()[indexName];
              if (value is Map && value.containsKey("id")) {
                value = value["id"];
              }

              if (value != null) {
                if (value is List || value is Map) {
                  indexable = false;
                  break;
                }
                point = "$value:${entity.id}";
              }
            }

            if (point != null) {
              index.points!.add(point);
            }
          }
        }
      }

      if (indexable) {
        await IndexHelper.saveIndex(
          storage: store,
          index: index,
          type: type,
          colName: indexName,
        );
      }
    }
  }

  Future<int> queryCount<T extends DataType>(QueryImpl<T> query) async {
    return (await this.query(query)).length;
  }
}
