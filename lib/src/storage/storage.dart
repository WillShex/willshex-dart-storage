//
//  Storage.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/src/storage/cmd/compactor.dart';
import 'package:willshex_storage/src/storage/cmd/deleter.dart';
import 'package:willshex_storage/src/storage/cmd/loader.dart';
import 'package:willshex_storage/src/storage/cmd/saver.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Storage {
  static const String VERSION = "0.0.2";

  Loader get load;

  Saver get save;

  Deleter get delete;

  Storage cache(bool cache);

  Compactor get compact;
}
