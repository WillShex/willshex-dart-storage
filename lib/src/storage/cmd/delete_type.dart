//
//  DeleteType.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
abstract class DeleteType implements DeleteIds {
  Future<void> entity<T extends DataType>(T entity);

  Future<void> entities<T extends DataType>(Iterable<T> entities);
}
