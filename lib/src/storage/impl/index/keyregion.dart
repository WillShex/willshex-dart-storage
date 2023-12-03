//
//  keyregion.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 23 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/src/abstracttree.dart';

class KeyRegion implements Region<int> {
  final int start;
  final int end;

  final int halfWay;

  KeyRegion(this.start, this.end) : halfWay = ((end - start) * 0.5).round();

  @override
  bool contains(int t) {
    return t >= start && t < end;
  }

  @override
  bool intersects(Region<int> region) {
    return _intersects(region as KeyRegion);
  }

  bool _intersects(KeyRegion region) {
    return region.contains(start) || region.contains(end);
  }

  @override
  Region<int> split(int value) {
    KeyRegion part;
    switch (value) {
      case 0:
        part = KeyRegion(start, halfWay);
        break;
      case 1:
        part = KeyRegion(halfWay, end);
        break;
      default:
        throw Exception("value can only be 0 or 1");
    }

    return part;
  }
}
