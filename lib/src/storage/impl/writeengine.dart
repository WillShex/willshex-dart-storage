//
//  WriteEngine.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:universal_file/universal_file.dart';
import 'package:willshex_dart_storage/src/storage/impl/storageimpl.dart';
import 'package:willshex_dart_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
class WriteEngine {
  StorageImpl<Storage> store;

  WriteEngine(this.store);

  Future<Map<int, T>> save<T extends DataType>(final Iterable<T> entities) {
    return Future<Map<int, T>>(() async {
      Class<T>? type;
      Map<int, T> saved = <int, T>{};

      List<T>? insert;
      List<T>? update;
      for (T entity in entities) {
        if (type == null) {
          type = entity.sc as Class<T>;
        }

        if (entity.id == null) {
          if (insert == null) {
            insert = <T>[];
          }
          insert.add(entity);
        } else {
          if (update == null) {
            update = <T>[];
          }
          update.add(entity);
        }
      }

      if (insert != null) {
        saved.addAll(await _insert(type!, insert));
      }

      if (update != null) {
        saved.addAll(await _update(type!, update));
      }
      return saved;
    });
  }

  Future<void> delete<T>(final Class<T> type, final Iterable<int> ids) {
    return Future<void>(() async {
      File recordFileHandle;
      Directory folder = await store.ensureFolder(type.simpleName);
      for (int id in ids) {
        recordFileHandle = File("${folder.path}/${id.toString()}.json");
        if (await recordFileHandle.exists()) {
          await recordFileHandle.delete();
        }

        if (store.useCache) {
          store.ensureCache().remove(id.toString());
        }
      }
    });
  }

  Future<void> compact<T extends DataType>(Class<T> type) {
    return Future<void>(() async {});
  }

  Future<int> _nextAutoIncrement<T extends DataType>(
      Class<T> type, int increment) async {
    return _incrementCounter(type, "autoinc", increment);
  }

  Future<int> getAutoIncrement<T extends DataType>(Class<T> type) {
    return _getCounter(type, "autoinc");
  }

  Future<void> _setAutoIncrement<T extends DataType>(
      Class<T> type, int value) async {
    await _setCounter(type, "autoinc", value);
  }

  Future<int> _incrementCounter<T extends DataType>(
      Class<T> type, String name, int increment) async {
    int next = await _getCounter(type, name) + increment;
    await _setCounter(type, name, next);
    return next;
  }

  Future<void> _setCounter<T extends DataType>(
      Class<T> type, String name, int value) async {
    Directory folder = await store.ensureFolder(type.simpleName);
    File counterFileHandle = File("${folder.path}/_.$name");
    await counterFileHandle.writeAsString(value.toString());
  }

  Future<int> _getCounter<T extends DataType>(
      Class<T> type, String name) async {
    int counter;
    Directory folder = await store.ensureFolder(type.simpleName);
    File counterFileHandle = File("${folder.path}/_.$name");
    if (await counterFileHandle.exists()) {
      counter = int.parse(await counterFileHandle.readAsString());
    } else {
      counter = 1;
    }
    return counter;
  }

  Future<Map<int, T>> _insert<T extends DataType>(
      Class<T> type, List<T> entities) async {
    Map<int, T> inserted = <int, T>{};
    Directory folder = await store.ensureFolder(type.simpleName);
    int id = await _nextAutoIncrement(type, entities.length);
    id -= entities.length;
    for (T entity in entities) {
      entity.id = id;
      await File("${folder.path}/${id.toString()}.json")
          .writeAsString(entity.toStorable());
      inserted[id] = entity;

      if (store.useCache) {
        store.ensureCacheType(type)[id] = entity;
      }

      id++;
    }

    return inserted;
  }

  Future<Map<int, T>> _update<T extends DataType>(
      Class<T> type, List<T> entities) async {
    Map<int, T> updated = <int, T>{};
    int autoInc;
    Directory folder = await store.ensureFolder(type.simpleName);
    for (T entity in entities) {
      autoInc = await getAutoIncrement(type);
      if (entity.id! > autoInc) {
        await _setAutoIncrement(type, autoInc = entity.id!);
      }

      await File("${folder.path}/${entity.id.toString()}.json")
          .writeAsString(entity.toStorable());
      updated[entity.id!] = entity;

      if (store.useCache) {
        store.ensureCacheType(type)[entity.id!] = entity;
      }
    }

    return updated;
  }
}
