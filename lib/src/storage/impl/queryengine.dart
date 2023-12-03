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
import 'package:path/path.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_dart_storage/src/storage/impl/helper/queryhelper.dart';
import 'package:willshex_dart_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/order.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/storageimpl.dart';
import 'package:willshex_dart_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
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
    List<int> ids = <int>[]..length = entities.length;
    for (T entity in entities) {
      ids.add(entity.id!);
    }
    return ids;
  }

  Future<List<T>> query<T extends DataType>(QueryImpl<T> query) async {
    if (query.dataClass == null)
      throw AssertionError("Cannot query without a type");

    Directory folder = await store.ensureFolder(query.dataClass!.simpleName);
    Stream<FileSystemEntity> records = Directory("${folder.path}").list();

    List<Map<String, dynamic>> objects = <Map<String, dynamic>>[];

    // int startAt = query.startAt == null ? 0 : query.startAt;
    int matchedCount = 0;
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
          // if (matchedCount >= startAt) {
          objects.add(object);
          // if (query.stopAfter != null &&
          //     matchedCount - startAt == query.stopAfter - 1) break;
          // }
          matchedCount++;
        }
      }
    }

    _log.fine("Matched count ${query.dataClass?.name}: $matchedCount");

    // TODO: process distinct and group

    QueryHelper.sort(
        objects, query.allOrders == null ? DEFAULT_ORDER : query.allOrders);

    if (query.startAt != 0) {
      objects = objects.sublist(query.startAt);
    }

    int end;
    if ((end = query.stopAfter + 1) < objects.length) {
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
        matched.add(loaded[object["id"]]!);
      }
    }

    return matched;
  }

  Future<int> queryCount<T extends DataType>(QueryImpl<T> query) async {
    return (await this.query(query)).length;
  }
}
