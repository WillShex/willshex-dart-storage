//
//  StorageImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:universal_file/universal_file.dart';
import 'package:willshex/src/datatype.dart';
import 'package:willshex_dart_storage/src/storage/class.dart';
import 'package:willshex_dart_storage/src/storage/cmd/compactor.dart';
import 'package:willshex_dart_storage/src/storage/cmd/deleter.dart';
import 'package:willshex_dart_storage/src/storage/cmd/loader.dart';
import 'package:willshex_dart_storage/src/storage/cmd/saver.dart';
import '../../../../storage.dart';

import 'package:willshex_dart_storage/src/storage/impl/compactorimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/deleterimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/saverimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/writeengine.dart';

typedef Future<String> PathProvider();

///
/// @author William Shakour (billy1380)
///
class StorageImpl<S extends Storage> extends Storage {
  Directory? _storageHandle;
  PathProvider _pathProvider;
  bool? _useCache;
  Map<String, Map<int, dynamic>>? c;

  bool get useCache {
    return _useCache ?? false;
  }

  set useCache(bool value) => _useCache = value;

  StorageImpl(this._pathProvider);

  Future<Directory> get folder async {
    if (_storageHandle == null) {
      String path = await _pathProvider();
      _storageHandle = Directory("$path");
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
    Directory folder = Directory("${parent.path}/$name");

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
