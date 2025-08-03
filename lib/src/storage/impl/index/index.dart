//
//  index.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 22 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/src/abstract_tree.dart';

class Index<T> extends AbstractTree<T> {
  final String name;

  Index(this.name) : super(() => _creator(name), 2);

  static Index<T> _creator<T>(String name) {
    return Index<T>(name);
  }

  static Index<T> createIndex<T>(String name, Region<T> region, int capacity) {
    return AbstractTree.createTree(region, capacity, () => _creator(name))
        as Index<T>;
  }
}
