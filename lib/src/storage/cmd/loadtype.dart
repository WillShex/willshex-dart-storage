//
//  LoadType.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/src/datatype.dart';
import 'package:willshex_dart_storage/src/storage/cmd/loadids.dart';
import 'package:willshex_dart_storage/src/storage/cmd/query.dart';

///
/// @author William Shakour (billy1380)
///
abstract class LoadType<T extends DataType> implements LoadIds<T>, Query<T> {}
