//
//  QueryImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_storage/src/storage/impl/filter.dart';
import 'package:willshex_storage/src/storage/impl/loaderimpl.dart';
import 'package:willshex_storage/src/storage/impl/order.dart';
import 'package:willshex_storage/src/storage/impl/simplequeryimpl.dart';
import 'package:willshex_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
class QueryImpl<T extends DataType> extends SimpleQueryImpl<T>
    implements Query<T>, Cloneable<QueryImpl<T>> {
  // static final Logger _log = Logger("QueryImpl");
  List<Order>? _order;
  List<Filter>? _filters;
  List<String>? _group;

  int stopAfter = 100;
  int startAt = 0;
  bool isReverse = false;
  bool isDistinct = false;
  bool isIdsOnly = false;

  QueryImpl._() : super.protected();

  QueryImpl(LoaderImpl<Loader> loader) : super(loader);

  QueryImpl.typed(LoaderImpl<Loader> loader, Class<T> type) : super(loader) {
    this.dataClass = type;
  }

  @override
  QueryImpl<T> createQuery() {
    return this.clone();
  }

  @override
  QueryImpl<T> clone() {
    QueryImpl<T> impl = super.clone() as QueryImpl<T>;
    if (this._order != null) {
      impl._order = <Order>[]..addAll(this._order!);
    }

    if (this._filters != null) {
      impl._filters = <Filter>[]..addAll(this._filters!);
    }

    if (this._group != null) {
      impl._group = <String>[]..addAll(this._group!);
    }

    return impl
      ..loader = impl.loader
      ..dataClass = this.dataClass
      ..startAt = this.startAt
      ..stopAfter = this.stopAfter
      ..isReverse = this.isReverse
      ..isDistinct = this.isDistinct
      ..isIdsOnly = this.isIdsOnly;
  }

  void addOrder(String condition) {
    condition = condition.trim();
    SortDirectionType direction = SortDirectionType.ascending;

    if (condition.startsWith("-")) {
      direction = SortDirectionType.descending;
      condition = condition.substring(1).trim();
    }

    _ensureOrder().add(Order(condition, direction));
  }

  void addFilter(String condition, dynamic value) {
    late FilterOperation filterOperation;
    String filterFieldName;
    Object filterValue;

    condition = condition.trim();
    bool foundOperation = false;
    for (FilterOperation operation in FilterOperation.values) {
      String? sign = fromFilterOperationToString(operation);
      if (condition.endsWith(sign!)) {
        filterOperation = operation;
        condition = condition
            .replaceRange(condition.length - sign.length, condition.length, "")
            .trim();
        foundOperation = true;
        break;
      }
    }

    if (!foundOperation) {
      filterOperation = FilterOperation.Equals;
    }

    filterFieldName = condition;
    filterValue = value;

    _ensureFilters().add(Filter(
      fieldName: filterFieldName,
      value: filterValue,
      operation: filterOperation,
    ));
  }

  void addGroup(String condition) {
    condition = condition.trim();
    _ensureGroup().add(condition);
  }

  List<Order> _ensureOrder() {
    if (_order == null) {
      _order = <Order>[];
    }

    return _order!;
  }

  List<Filter> _ensureFilters() {
    if (_filters == null) {
      _filters = <Filter>[];
    }

    return _filters!;
  }

  List<String> _ensureGroup() {
    if (_group == null) {
      _group = <String>[];
    }

    return _group!;
  }

  Future<Iterable<T>> resultIterable() async {
    return loader!.createQueryEngine().query(this);
  }

  void toggleReverse() => isReverse = !isReverse;

  @override
  Future<int> get count async {
    return await loader!.createQueryEngine().queryCount(this);
  }

  @override
  Future<List<T>> get list async {
    return await loader!.createQueryEngine().query(this);
  }

  @override
  Future<T?> get first {
    return Future<T?>(() async {
      Iterator<T> entities = (await limit(1).resultIterable()).iterator;
      return entities.moveNext() ? entities.current : null;
    });
  }

  @override
  Query<T> filter(String condition, dynamic value) {
    QueryImpl<T> q = createQuery();
    q.addFilter(condition, value);
    return q;
  }

  @override
  QueryImpl<T> order(String condition) {
    QueryImpl<T> q = createQuery();
    q.addOrder(condition);
    return q;
  }

  @override
  QueryImpl<T> group(String condition) {
    QueryImpl<T> q = createQuery();
    q.addGroup(condition);
    return q;
  }

  @override
  SimpleQueryImpl<T> get newInstance {
    return QueryImpl<T>._();
  }

  List<Filter>? get allFilters => this._filters;
  List<Order>? get allOrders => this._order;
  List<String>? get allGroups => this._group;
}
