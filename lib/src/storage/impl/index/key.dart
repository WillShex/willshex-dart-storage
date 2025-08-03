//
//  key.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 22 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/src/storage/impl/index/index.dart';
import 'package:willshex_storage/src/storage/impl/index/keyregion.dart';

class Key extends Index<int> {
  static const int max = 4294967296;
  static const String indexName = "id";

  Key._() : super(indexName);

  static Key createKey([int capacity = 10]) =>
      Index.createIndex(indexName, KeyRegion(0, max), capacity) as Key;
}
