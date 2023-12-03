//
//  Saver.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex/willshex.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Saver {
  Future<int> entity<E extends DataType>(E entity);

  Future<Map<int, E>> entities<E extends DataType>(Iterable<E> entities);
}
