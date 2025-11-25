//
//  index.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 22 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:fs_shim/fs_shim.dart';
import 'package:meta/meta.dart';
import 'package:willshex/src/abstract_tree.dart';

@internal
class Index<T> extends AbstractTree<T> {
  final String name;

  @internal
  File? indexFile;
  @internal
  List<File>? childFiles;

  Index(this.name) : super(() => _creator(name), 2);

  static Index<T> _creator<T>(String name) {
    return Index<T>(name);
  }

  static Index<T> createIndex<T>(String name, Region<T> region, int capacity) {
    return AbstractTree.createTree<T>(region, capacity, () => _creator(name))
        as Index<T>;
  }
}
