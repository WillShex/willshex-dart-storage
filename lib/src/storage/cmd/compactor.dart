//
//  compactor.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:willshex_dart_storage/src/storage/class.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Compactor {
  Future<void> type<E>(Class<E> type);
}
