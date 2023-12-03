//
//  LoadIds.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex/src/datatype.dart';

///
/// @author William Shakour (billy1380)
///
abstract class LoadIds<T extends DataType> {
  Future<T?> id(int id);

  Future<Map<int, T>> ids(Iterable<int> ids);
}
