//
//  LoaderImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_dart_storage/src/storage/impl/loadengine.dart';
import 'package:willshex_dart_storage/src/storage/impl/loadtypeimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryable.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryengine.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/simplequeryimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/storageimpl.dart';
import 'package:willshex_dart_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
class LoaderImpl<L extends Loader> extends Queryable<DataType>
    implements Loader, Cloneable<dynamic> {
  // static final Logger _log = Logger("LoaderImpl");

  late StorageImpl<Storage> store;

  LoaderImpl._() : super.protected();
  LoaderImpl(this.store) : super(null);

  @override
  LoadType<E> type<E extends DataType>(Class<E> type) {
    return LoadTypeImpl<E>(this, type);
  }

  @override
  QueryImpl<DataType> createQuery() {
    return QueryImpl<DataType>(this);
  }

  @override
  Future<Map<int, E>> entities<E extends DataType>(Iterable<E> entities) {
    LoadEngine engine = createLoadEngine();

    List<int> ids = <int>[];
    Class<E>? type;
    for (E entity in entities) {
      if (type == null) {
        type = entity.sc as Class<E>;
      }

      ids.add(entity.id!);
    }

    return engine.load(type!, ids);
  }

  LoadEngine createLoadEngine() {
    return LoadEngine(this, store);
  }

  QueryEngine createQueryEngine() {
    return QueryEngine(this, store);
  }

  @override
  Future<E?> now<E extends DataType>(Class<E> type, int id) async {
    Map<int, E> loaded = await createLoadEngine().load(type, <int>[id]);
    return loaded.values.isNotEmpty ? loaded.values.first : null;
  }

  LoaderImpl<L> clone() => super.clone() as LoaderImpl<L>;

  @override
  Future<E?> entity<E extends DataType>(final E entity) {
    return Future<E?>(() async {
      Map<int, E> entities = await this.entities(<E>[entity]);
      return entities.values.isNotEmpty ? entities.values.first : null;
    });
  }

  @override
  Future<T?> id<T extends DataType>(final Class<T> type, final int id) {
    return Future<T?>(() async {
      Map<int, T> entities = await this.ids(type, <int>[id]);
      return entities.values.isNotEmpty ? entities.values.first : null;
    });
  }

  @override
  Future<Map<int, T>> ids<T extends DataType>(
      Class<T> type, Iterable<int> ids) {
    return createLoadEngine().load(type, ids);
  }

  @override
  SimpleQueryImpl<DataType> get newInstance {
    return LoaderImpl<Loader>._();
  }
}
