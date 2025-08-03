//
//  indexhelper.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/src/storage/impl/index/index.dart';
import 'package:willshex_storage/src/storage/impl/index/key.dart';
import 'package:willshex_storage/src/storage/impl/storageimpl.dart';

import '../../../../../storage.dart';

///
/// @author William Shakour (billy1380)
///
class IndexHelper {
  static final Logger _log = Logger("IndexHelper");

  static Future<Index<I>?> loadIndex<T, I>({
    required StorageImpl<Storage> storage,
    required Class<T> type,
    required String colName,
    String? path,
  }) async {
    // TODO: load index
    return null;
  }

  static Future<void> saveIndex<T, I>({
    required StorageImpl<Storage> storage,
    required Index<I> index,
    required Class<T> type,
    required String colName,
    String? path,
  }) async {
    Directory indexFolder = Directory(
        "${(await storage.ensureFolder(type.simpleName)).path}/.index/");

    // remove .index folder
    if (await indexFolder.exists() && path == null) {
      await indexFolder.delete(
        recursive: true,
      );

      // recreate the folder
      await indexFolder.create();
    }

    if (index.points != null) {
      File pointsFile =
          File("${indexFolder.absolute.path}${colName}${path ?? ""}");
      pointsFile = await pointsFile.create(
        recursive: true,
      );

      await pointsFile.writeAsBytes(
          utf8.encode((index.points!.map((I e) => e.toString()).join("\n"))));

      for (int i = 0; i < index.children.length; i++) {
        if (index.children[i] != null) {
          await saveIndex(
              storage: storage,
              index: index.children[i] as Index<I>,
              type: type,
              colName: colName,
              path: _path(path, i));
        }
      }
    }
  }

  static Future<void> saveKey<T>({
    required StorageImpl<Storage> storage,
    required Key key,
    required Class<T> type,
    String? path,
  }) {
    return saveIndex(
      storage: storage,
      index: key,
      type: type,
      colName: key.name,
      path: path,
    );
  }

  static Future<Key?> loadKey<T>({
    required StorageImpl<Storage> storage,
    required Class<T> type,
    required String colName,
    String? path,
  }) {
    return loadIndex(
      storage: storage,
      type: type,
      colName: Key.indexName,
    ) as Future<Key?>;
  }

  static String _path(String? path, int index) {
    return path == null ? "${index}" : "${path}_${index}";
  }

  static double weigh(String s) {
    double value = 0.0;
    for (int i = 0; i < s.length; i++) {
      value += s.codeUnitAt(i) * pow(10.0, -i);
    }

    _log.info("$s weighs: $value");

    return value;
  }
}
