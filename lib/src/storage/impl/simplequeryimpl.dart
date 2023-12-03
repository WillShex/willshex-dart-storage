//
//  SimpleQueryImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_dart_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryimpl.dart';
import 'package:willshex_dart_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
abstract class SimpleQueryImpl<T extends DataType> implements SimpleQuery<T> {
  LoaderImpl<Loader>? loader;
  Class<T>? dataClass;

  SimpleQueryImpl.protected();

  SimpleQueryImpl(LoaderImpl<Loader>? loader) {
    this.loader = (loader == null ? this : loader) as LoaderImpl<Loader>;
  }

  @override
  QueryImpl<T> limit(int value) {
    QueryImpl<T> q = createQuery();
    q.stopAfter = value;
    return q;
  }

  @override
  QueryImpl<T> offset(int value) {
    QueryImpl<T> q = createQuery();
    q.startAt = value;
    return q;
  }

  QueryImpl<T> createQuery();

  @override
  QueryImpl<T> filterId(String condition, dynamic value) {
    QueryImpl<T> q = createQuery();
    q.addFilter("id " + condition, value);
    return q;
  }

  @override
  QueryImpl<T> distinct(bool value) {
    QueryImpl<T> q = createQuery();
    q.isDistinct = value;
    return q;
  }

  @override
  QueryImpl<T> reverse() {
    QueryImpl<T> q = createQuery();
    q.toggleReverse();
    return q;
  }

  @override
  QueryExecute<int> get allIds {
    final QueryImpl<T> q = createQuery();
    q.isIdsOnly = true;
    return QueryExecute<int>(() {
      return Future<int>(() async {
        List<int> ids = await loader!.createQueryEngine().queryIds(q.limit(1));
        return ids.first;
      });
    }, () async {
      return loader!.createQueryEngine().queryIds(q);
    });
  }

  SimpleQueryImpl<T> clone() {
    SimpleQueryImpl<T>? impl = newInstance;

    if (impl == null) throw Exception("SimpleQueryImpl");

    impl.loader = this.loader;
    impl.dataClass = this.dataClass;

    return impl;
  }

  SimpleQueryImpl<T>? get newInstance;
}
