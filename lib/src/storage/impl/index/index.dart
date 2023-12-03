//
//  index.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 22 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/src/abstracttree.dart';

class Index<T> extends AbstractTree<T> {
  Index() : super(_creator, 2);

  static Index<T> _creator<T>() {
    return Index<T>();
  }

  static Index<T> createIndex<T>(Region<T> region, int capacity) {
    return AbstractTree.createTree(region, capacity, _creator) as Index<T>;
  }
}
