//
//  WriteEngine.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import "dart:async";

import "package:fs_shim/fs_shim.dart";
import "package:meta/meta.dart";
import "package:path/path.dart" as path;
import "package:willshex_storage/src/storage/impl/helper/index_helper.dart";
import "package:willshex_storage/src/storage/impl/index/index.dart";
import "package:willshex_storage/src/storage/impl/index/key.dart";
import "package:willshex_storage/src/storage/impl/file_system_access.dart";
import "package:willshex_storage/src/storage/impl/storage_impl.dart";
import "package:willshex_storage/storage.dart";

///
/// @author William Shakour (billy1380)
///
@internal
class WriteEngine {
  StorageImpl<Storage> store;

  WriteEngine(this.store);

  Future<Map<int, T>> save<T extends DataType>(final Iterable<T> entities) {
    return Future<Map<int, T>>(() async {
      Class<T>? type;
      Map<int, T> saved = <int, T>{};

      List<T>? insert;
      List<T>? update;
      for (final T entity in entities) {
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

  Future<void> delete<T extends DataType>(
      final Class<T> type, final Iterable<int> ids) {
    return Future<void>(() async {
      File recordFileHandle;
      Directory folder = await store.ensureFolder(type.simpleName);

      List<T> entities = <T>[];
      for (final int id in ids) {
        recordFileHandle = fs.file("${folder.path}/${id.toString()}.json");
        if (await recordFileHandle.exists()) {
          T entity = type.instance();
          entity.fromString(await recordFileHandle.readAsString());
          if (entity.id != null) {
            entities.add(entity);
          }
        }
      }

      await _updateIndices<T>(type, entities, false);

      for (final int id in ids) {
        recordFileHandle = fs.file("${folder.path}/${id.toString()}.json");
        if (await recordFileHandle.exists()) {
          await recordFileHandle.delete();
        }

        if (store.useCache) {
          store.ensureCache().remove(id.toString());
        }
      }
    });
  }

  Future<void> drop<T extends DataType>(Class<T> type) {
    return Future<void>(() async {
      Directory parent = await store.folder;
      Directory folder = fs.directory("${parent.path}/${type.simpleName}");

      if (await folder.exists()) {
        await folder.delete(recursive: true);
      }

      if (store.useCache) {
        store.ensureCacheType(type).clear();
      }
    });
  }

  Future<void> deleteAll<T extends DataType>(Class<T> type) {
    return Future<void>(() async {
      Directory folder = await store.ensureFolder(type.simpleName);
      List<int> ids = <int>[];

      if (await folder.exists()) {
        List<FileSystemEntity> files = await folder.list().toList();
        for (final FileSystemEntity file in files) {
          if (file is File) {
            String name = path.basename(file.path);
            if (name.endsWith(".json") && !name.startsWith("_")) {
              int? id = int.tryParse(name.substring(0, name.length - 5));
              if (id != null) {
                ids.add(id);
              }
            }
          }
        }
      }

      if (ids.isNotEmpty) {
        await delete(type, ids);
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
    File counterFileHandle = fs.file("${folder.path}/_.$name");
    await counterFileHandle.writeAsString(value.toString());
  }

  Future<int> _getCounter<T extends DataType>(
      Class<T> type, String name) async {
    int counter;
    Directory folder = await store.ensureFolder(type.simpleName);
    File counterFileHandle = fs.file("${folder.path}/_.$name");
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
    for (final T entity in entities) {
      entity.id = id;
      await fs
          .file("${folder.path}/${id.toString()}.json")
          .writeAsString(entity.toStorable());
      inserted[id] = entity;

      if (store.useCache) {
        store.ensureCacheType(type)[id] = entity;
      }

      id++;
    }

    await _updateIndices(type, entities, true);

    return inserted;
  }

  Future<Map<int, T>> _update<T extends DataType>(
      Class<T> type, List<T> entities) async {
    Map<int, T> updated = <int, T>{};
    int autoInc;
    Directory folder = await store.ensureFolder(type.simpleName);
    for (final T entity in entities) {
      autoInc = await getAutoIncrement(type);
      if (entity.id! > autoInc) {
        await _setAutoIncrement(type, autoInc = entity.id!);
      }

      await fs
          .file("${folder.path}/${entity.id.toString()}.json")
          .writeAsString(entity.toStorable());
      updated[entity.id!] = entity;

      if (store.useCache) {
        store.ensureCacheType(type)[entity.id!] = entity;
      }
    }

    await _updateIndices(type, entities, true);

    return updated;
  }

  Future<void> _updateIndices<T extends DataType>(
      Class<T> type, List<T> entities, bool add) async {
    Directory indexFolder = fs.directory(
        "${(await store.ensureFolder(type.simpleName)).path}/.index/");

    if (await indexFolder.exists()) {
      List<FileSystemEntity> files = await indexFolder.list().toList();
      for (final FileSystemEntity file in files) {
        if (file is File) {
          String name = path.basename(file.path);
          if (RegExp(r"_\d+$").hasMatch(name)) continue;

          Index<String>? index = await IndexHelper.loadIndex<T, String>(
            storage: store,
            type: type,
            colName: name,
          );

          if (index != null) {
            bool modified = false;
            bool isCompound =
                name.contains("_") && !RegExp(r"_\d+$").hasMatch(name);

            for (final T entity in entities) {
              String? point;
              if (name == Key.indexName) {
                point = entity.id.toString();
              } else if (isCompound) {
                List<String> fieldNames = name.split("_");
                List<String> values = [];
                bool skip = false;

                for (final String fieldName in fieldNames) {
                  final fieldValue = entity.toJson()[fieldName];
                  dynamic normalizedValue = fieldValue;
                  if (fieldValue is Map && fieldValue.containsKey("id")) {
                    normalizedValue = fieldValue["id"];
                  }
                  if (normalizedValue == null ||
                      normalizedValue is List ||
                      normalizedValue is Map) {
                    skip = true;
                    break;
                  }
                  values.add("$normalizedValue");
                }

                if (!skip) {
                  point = "${values.join("&")}:${entity.id}";
                }
              } else {
                final Object? fieldValue = entity.toJson()[name];
                dynamic normalizedValue = fieldValue;
                if (fieldValue is Map && fieldValue.containsKey("id")) {
                  normalizedValue = fieldValue["id"];
                }

                if (normalizedValue != null) {
                  if (normalizedValue is List || normalizedValue is Map) {
                    continue;
                  }
                  point = "$normalizedValue:${entity.id}";
                }
              }

              if (point != null) {
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
  }
}
