//
//  StorageImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import "dart:async";

import "package:fs_shim/fs_shim.dart";
import "package:meta/meta.dart";
import "package:path/path.dart" as path;
import "package:willshex_storage/src/storage/impl/compactor_impl.dart";
import "package:willshex_storage/src/storage/impl/deleter_impl.dart";
import "package:willshex_storage/src/storage/impl/loader_impl.dart";
import "package:willshex_storage/src/storage/impl/read_write_lock.dart";
import "package:willshex_storage/src/storage/impl/saver_impl.dart";
import "package:willshex_storage/src/storage/impl/file_system_access.dart";
import "package:willshex_storage/src/storage/impl/write_engine.dart";
import "package:willshex_storage/storage.dart";

typedef PathProvider = FutureOr<String> Function();

///
/// @author William Shakour (billy1380)
///
@internal
class StorageImpl<S extends Storage> extends Storage {
  Directory? _storageHandle;
  PathProvider _pathProvider;
  bool? _useCache;
  Map<String, Map<int, dynamic>>? c;
  Map<String, Future<void>>? _indexBuilds;
  Map<String, ReadWriteLock>? _fileLocks;

  bool get useCache {
    return _useCache ?? false;
  }

  set useCache(bool value) => _useCache = value;

  Map<String, Future<void>> get indexBuilds =>
      _indexBuilds ??= <String, Future<void>>{};

  Map<String, ReadWriteLock> get fileLocks =>
      _fileLocks ??= <String, ReadWriteLock>{};

  /// many reads of a file can run together, but a write waits for them and
  /// blocks them, so a read never sees a half written record
  Future<T> readAccess<T>(String filePath, Future<T> Function() action) =>
      _access(filePath, (lock) => lock.read(action));

  Future<T> writeAccess<T>(String filePath, Future<T> Function() action) =>
      _access(filePath, (lock) => lock.write(action));

  Future<T> _access<T>(
      String filePath, Future<T> Function(ReadWriteLock lock) run) {
    String key = path.normalize(filePath);
    ReadWriteLock lock = fileLocks.putIfAbsent(key, ReadWriteLock.new);

    return run(lock).whenComplete(() {
      if (lock.isIdle && identical(fileLocks[key], lock)) {
        fileLocks.remove(key);
      }
    });
  }

  StorageImpl(this._pathProvider);

  Future<Directory> get folder async {
    if (_storageHandle == null) {
      String path = await _pathProvider();
      _storageHandle = fs.directory("$path");
      if (await _storageHandle!.exists()) {
        // do nothing
      } else {
        await _storageHandle!.create(recursive: true);
      }
    }

    return _storageHandle!;
  }

  Future<Directory> ensureFolder(String name) async {
    Directory parent = await this.folder;
    Directory folder = fs.directory("${parent.path}/$name");

    if (await folder.exists()) {
      // do nothing
    } else {
      await folder.create(recursive: true);
    }

    return folder;
  }

  @override
  Loader get load {
    return LoaderImpl<Loader>(this);
  }

  @override
  Saver get save {
    return SaverImpl(this);
  }

  @override
  Deleter get delete {
    return DeleterImpl(this);
  }

  @override
  Storage cache(bool value) {
    useCache = value;
    return this;
  }

  @override
  Compactor get compact {
    return CompactorImpl(this);
  }

  Map<int, dynamic> ensureCacheType<T extends DataType>(Class<T> type) =>
      ensureCache<T>().putIfAbsent(type.name, () => <int, dynamic>{});

  Map<String, Map<int, dynamic>> ensureCache<T extends DataType>() {
    if (c == null) {
      c = <String, Map<int, dynamic>>{};
    }

    return c!.cast();
  }

  WriteEngine createWriteEngine() {
    return WriteEngine(this);
  }
}
