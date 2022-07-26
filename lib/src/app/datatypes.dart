import 'dart:async';

import 'package:willshex/willshex.dart';

abstract class DataTypes {
  static final Storage store = StorageProvider.provide(_path).cache(true);

  static Future<String> _path() {
    return new Future.value("./data");
  }
}
