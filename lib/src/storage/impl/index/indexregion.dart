//
//  indexregion.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 23 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/src/abstracttree.dart';
import 'package:willshex_dart_storage/src/storage/impl/index/pair.dart';

class IndexRegion<T extends num> implements Region<Pair<T, int>> {
  final T start;
  final T end;

  final T halfWay;

  IndexRegion(this.start, this.end)
      : halfWay = (start is int
            ? ((end - start) * 0.5).round()
            : (end - start) * 0.5) as T;

  bool _contains(T t) {
    return t >= start && t < end;
  }

  @override
  bool contains(Pair<T, int> t) {
    return _contains(t.key);
  }

  @override
  bool intersects(Region<Pair<T, int>> region) {
    return _intersects(region as IndexRegion<T>);
  }

  bool _intersects(IndexRegion<T> region) {
    throw region._contains(start) || region._contains(end);
  }

  @override
  Region<Pair<T, int>> split(int value) {
    Region<Pair<T, int>> part;

    switch (value) {
      case 0:
        part = IndexRegion<T>(start, halfWay);
        break;
      case 1:
        part = IndexRegion<T>(halfWay, end);
        break;
      default:
        throw Exception("value can only be 0 or 1");
    }

    return part;
  }
}

// void main(List<String> args) {
//   StringRegion s = StringRegion.weight(double.maxFinite * 0.5, double.maxFinite);
//   StringRegion t = StringRegion("abd", double.maxFinite);

//   bool sa = s.contains("abcd");
//   print("s contains abcd: $sa");

//   bool tc = t.contains("cdef");
//   print("t contains c: $tc");

//   StringRegion leftS = s.split(0);
//   StringRegion rightS = s.split(1);
// }
