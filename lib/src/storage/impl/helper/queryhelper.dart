//
//  queryhelper.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_dart_storage/src/storage/impl/filter.dart';
import 'package:willshex_dart_storage/src/storage/impl/order.dart';
import 'package:willshex_dart_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
class QueryHelper {
  static void sort(
      List<Map<String, dynamic>> objects, final List<Order>? order) {
    objects.sort((Map<String, dynamic> o1, Map<String, dynamic> o2) {
      dynamic value, value2;
      int result;
      if (order != null) {
        for (Order item in order) {
          value = o1[item.fieldName];
          value2 = o2[item.fieldName];

          if ((result = compareElements(value, value2)) > 0) {
            if (item.direction == SortDirectionType.ascending) {
              return -1;
            } else {
              return 1;
            }
          } else if (result < 0) {
            if (item.direction == SortDirectionType.ascending) {
              return 1;
            } else {
              return -1;
            }
          }
        }
      } else {
        return compareElements(o1["id"], o1["id"]);
      }

      return 0;
    });
  }

  static int compareElements(dynamic e, dynamic e2) {
    if (e == null && e2 != null) {
      return 1;
    } else if (e2 == null && e != null) {
      return -1;
    }

    if (e is List && e2 is List) {
      return compareArrays(e, e2);
    } else if (e is Map && e2 is Map) {
      return compareElements(e["id"], e2["id"]);
    } else if (_isJsonPrimitive(e)) {
      return comparePrimitives(e, e2);
    } else
      throw AssertionError(
          "Comparing objects [${e.toString()}] and [${e2.toString()}] which are of different types!");
  }

  static int compareArrays(List<dynamic> a1, List<dynamic> a2) {
    if (a1.length != a2.length) {
      return a1.length > a2.length ? -1 : 1;
    }
    return 0;
  }

  static int comparePrimitives(dynamic p1, dynamic p2) {
    if (p1 is bool && p2 is bool) {
      if (p1 != p2) {
        return p1 ? 1 : -1;
      }
    } else if (p1 is num && p2 is num) {
      if (p1 != p2) {
        return p1 > p2 ? -1 : 1;
      }
    } else if (p1 is String && p2 is String) {
      return p1.compareTo(p2);
    }
    return 0;
  }

  static bool isMatchAll(Map<String, dynamic> object, List<Filter>? filters) {
    bool isMatch = true;

    if (filters != null) {
      for (Filter filter in filters) {
        if (object.containsKey(filter.fieldName)) {
          isMatch = isMatch &&
              QueryHelper.isMatch(
                  object[filter.fieldName],
                  filter.operation,
                  _convertToStoredTypeIfDate(
                      filter.value, object[filter.fieldName]));
          if (!isMatch) break;
        } else {
          isMatch = false;
          break;
        }
      }
    }

    return isMatch;
  }

  static bool isMatch(
      dynamic toCompare, FilterOperation operation, dynamic against) {
    bool passed = false;

    switch (operation) {
      case FilterOperation.Equals:
        if (toCompare == null && against == null) {
          passed = true;
        } else if (_isJsonPrimitive(toCompare) &&
            toCompare is String &&
            against is String) {
          passed = (toCompare.compareTo(against) == 0);
        } else if (_isJsonPrimitive(toCompare) &&
            toCompare is num &&
            against is num) {
          passed = (toCompare == against);
        } else if (_isJsonPrimitive(toCompare) &&
            toCompare is bool &&
            against is bool) {
          passed = (toCompare == against);
        } else if (toCompare is Map &&
            toCompare["id"] != null &&
            toCompare["id"] is num) {
          if (against is num) {
            passed = (toCompare["id"] == against);
          } else if (against is DataType && against.id != null) {
            passed = (toCompare["id"] == against.id);
          }
        }
        // TODO: 6- possibly with lists of primitives that contain the same elements
        break;
      case FilterOperation.GreaterThan:
        passed = _isJsonPrimitive(toCompare) &&
            comparePrimitives(toCompare, against) > 0;
        break;
      case FilterOperation.GreaterThanOrEqual:
        passed = !isMatch(toCompare, FilterOperation.LessThan, against);
        break;
      case FilterOperation.In:
        if (against is Iterable) {
          Iterable<dynamic> iterable = against;

          for (dynamic againsItem in iterable) {
            passed = isMatch(toCompare, FilterOperation.Equals, againsItem);
            if (passed) break;
          }
        }
        break;
      case FilterOperation.LessThan:
        passed = _isJsonPrimitive(toCompare) &&
            comparePrimitives(toCompare, against) < 0;
        break;
      case FilterOperation.LessThanOrEqual:
        passed = !isMatch(toCompare, FilterOperation.GreaterThan, against);
        break;
      case FilterOperation.NotEquals:
        passed = !isMatch(toCompare, FilterOperation.Equals, against);
        break;
    }

    return passed;
  }

  static bool _isJsonPrimitive(dynamic value) {
    return !(value is Map || value is List);
  }

  static dynamic _convertToStoredTypeIfDate(dynamic value, dynamic stored) {
    dynamic converted = value;

    if (value is DateTime) {
      if (stored is String) {
        converted = value.toIso8601String();
      } else if (value is int) {
        converted = value.millisecondsSinceEpoch;
      }
    }

    return converted;
  }
}
