//
//  Deleter.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex/willshex.dart';
import 'package:willshex_dart_storage/src/storage/class.dart';
import 'package:willshex_dart_storage/src/storage/cmd/deletetype.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Deleter {
  DeleteType type<T extends DataType>(Class<T> type);

  Future<void> entity<T extends DataType>(T entity);

  Future<void> entities<T extends DataType>(Iterable<T> entities);
}
