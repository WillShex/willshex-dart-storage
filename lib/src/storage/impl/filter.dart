//
//  Condition.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:meta/meta.dart';

///
/// @author William Shakour (billy1380)
///
@internal
enum FilterOperation {
  NotEquals,
  GreaterThan,
  GreaterThanOrEqual,
  LessThan,
  LessThanOrEqual,
  In,
  Equals,
}

@internal
class Filter {
  FilterOperation operation;
  String fieldName;
  Object value;

  Filter({
    required this.operation,
    required this.fieldName,
    required this.value,
  });
}

@internal
String? fromFilterOperationToString(FilterOperation? value) {
  String? filterOperation;

  if (value != null) {
    switch (value) {
      case FilterOperation.NotEquals:
        filterOperation = "!=";
        break;
      case FilterOperation.GreaterThan:
        filterOperation = ">";
        break;
      case FilterOperation.GreaterThanOrEqual:
        filterOperation = ">=";
        break;
      case FilterOperation.LessThan:
        filterOperation = "<";
        break;
      case FilterOperation.LessThanOrEqual:
        filterOperation = "<=";
        break;
      case FilterOperation.In:
        filterOperation = "in";
        break;
      case FilterOperation.Equals:
        filterOperation = "=";
        break;
    }
  }

  return filterOperation;
}

@internal
FilterOperation? fromStringToFilterOperation(String? value) {
  FilterOperation? filterOperation;

  switch (value) {
    case "!=":
      filterOperation = FilterOperation.NotEquals;
      break;
    case ">":
      filterOperation = FilterOperation.GreaterThan;
      break;
    case ">=":
      filterOperation = FilterOperation.GreaterThanOrEqual;
      break;
    case "<":
      filterOperation = FilterOperation.LessThan;
      break;
    case "<=":
      filterOperation = FilterOperation.LessThanOrEqual;
      break;
    case "in":
      filterOperation = FilterOperation.In;
      break;
    case "=":
      filterOperation = FilterOperation.Equals;
      break;
  }

  return filterOperation;
}
