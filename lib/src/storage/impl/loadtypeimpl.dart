//
//  LoadTypeImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_storage/src/storage/impl/queryable.dart';
import 'package:willshex_storage/src/storage/impl/queryimpl.dart';
import 'package:willshex_storage/src/storage/impl/simplequeryimpl.dart';
import 'package:willshex_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
class LoadTypeImpl<T extends DataType> extends Queryable<T>
    implements LoadType<T> {
  LoadTypeImpl(LoaderImpl<Loader>? loader, Class<T>? type) : super(loader) {
    this.dataClass = type;
  }

  @override
  Future<T?> id(final int id) {
    return loader!.id(dataClass!, id);
  }

  @override
  Future<Map<int, T>> ids(Iterable<int> ids) {
    return loader!.ids(dataClass!, ids);
  }

  @override
  Query<T> filter(String condition, dynamic value) {
    QueryImpl<T> q = createQuery();
    q.addFilter(condition, value);
    return q;
  }

  @override
  Query<T> order(String condition) {
    QueryImpl<T> q = createQuery();
    q.addOrder(condition);
    return q;
  }

  @override
  Query<T> group(String condition) {
    QueryImpl<T> q = createQuery();
    q.addGroup(condition);
    return q;
  }

  @override
  QueryImpl<T> createQuery() {
    return QueryImpl<T>.typed(loader!, dataClass!);
  }

  @override
  SimpleQueryImpl<T> get newInstance {
    return LoadTypeImpl<T>(null, null);
  }
}
