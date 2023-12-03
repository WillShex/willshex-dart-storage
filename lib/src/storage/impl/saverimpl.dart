//
//  SaverImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex/willshex.dart';
import '../../../../storage.dart';
import 'package:willshex_dart_storage/src/storage/cmd/saver.dart';
import 'package:willshex_dart_storage/src/storage/impl/storageimpl.dart';

///
/// @author William Shakour (billy1380)
///
class SaverImpl implements Saver {
  StorageImpl<Storage> store;

  SaverImpl(this.store);

  @override
  Future<int> entity<E extends DataType>(E entity) {
    return Future<int>(() async {
      Map<int, E> saved = await entities(<E>[entity]);
      return saved.values.first.id!;
    });
  }

  @override
  Future<Map<int, E>> entities<E extends DataType>(Iterable<E> entities) {
    return store.createWriteEngine().save(entities);
  }
}
