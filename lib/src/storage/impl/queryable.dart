//
//  Queryable.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex/willshex.dart';
import 'package:willshex_dart_storage/src/storage/cmd/loader.dart';
import 'package:willshex_dart_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/queryimpl.dart';
import 'package:willshex_dart_storage/src/storage/impl/simplequeryimpl.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Queryable<T extends DataType> extends SimpleQueryImpl<T> {
  Queryable.protected() : super.protected();

  Queryable(LoaderImpl<Loader>? loader) : super(loader);

  @override
  Future<T?> get first {
    QueryImpl<T> q = createQuery();
    return q.first;
  }

  @override
  Future<int> get count {
    QueryImpl<T> q = createQuery();
    return q.count;
  }

  @override
  Future<List<T>> get list async {
    QueryImpl<T> q = createQuery();
    return q.list;
  }

  Queryable<T> clone() {
    return super.clone() as Queryable<T>;
  }
}
