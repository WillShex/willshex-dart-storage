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
import 'package:meta/meta.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/src/storage/impl/index/index.dart';
import 'package:willshex_storage/src/storage/impl/index/key.dart';
import 'package:willshex_storage/src/storage/impl/index/pair.dart';
import 'package:willshex_storage/src/storage/impl/storage_impl.dart';

import '../../../../../storage.dart';

///
/// @author William Shakour (billy1380)
///
@internal
class IndexHelper {
  static final Logger _log = Logger("IndexHelper");

  static Future<Index<I>?> loadIndex<T, I>({
    required StorageImpl<Storage> storage,
    required Class<T> type,
    required String colName,
    String? path,
  }) async {
    Directory indexFolder = Directory(
        "${(await storage.ensureFolder(type.simpleName)).path}/.index/");

    File pointsFile =
        File("${indexFolder.absolute.path}${colName}${path ?? ""}");

    if (!await pointsFile.exists()) {
      return null;
    }

    final Index<I> index;
    if (colName == Key.indexName && I == int) {
      index = Key.createKey() as Index<I>;
    } else {
      index = Index<I>(colName);
    }

    final List<String> lines = await pointsFile.readAsLines();

    if (I == String) {
      index.points = lines as List<I>;
    } else if (I == int) {
      index.points = lines.map((l) => int.parse(l)).toList() as List<I>;
    } else if (I == double) {
      index.points = lines.map((l) => double.parse(l)).toList() as List<I>;
    } else if (I == num) {
      index.points = lines.map((l) => num.parse(l)).toList() as List<I>;
    } else if (I == bool) {
      index.points =
          lines.map((l) => l.toLowerCase() == "true").toList() as List<I>;
    } else if (I == Pair<String, int>) {
      index.points =
          lines.map((l) => Pair.fromString<String, int>(l)).toList() as List<I>;
    } else if (I == Pair<int, int>) {
      index.points =
          lines.map((l) => Pair.fromString<int, int>(l)).toList() as List<I>;
    } else if (I == Pair<double, int>) {
      index.points =
          lines.map((l) => Pair.fromString<double, int>(l)).toList() as List<I>;
    } else if (I == Pair<bool, int>) {
      index.points =
          lines.map((l) => Pair.fromString<bool, int>(l)).toList() as List<I>;
    } else {
      throw UnsupportedError("Loading index for type $I is not supported. "
          "Only String, int, double, num, bool and Pair<*, int> are supported.");
    }

    final String prefix = path == null ? "" : "${path}_";
    final List<FileSystemEntity> allFiles = await indexFolder.list().toList();
    final List<int> childIndices = [];
    final String colPrefix = colName;

    for (final file in allFiles) {
      final String fileName =
          file.absolute.path.substring(indexFolder.absolute.path.length);
      if (!fileName.startsWith(colPrefix)) continue;

      final String pathCandidate = fileName.substring(colPrefix.length);

      if (pathCandidate.isEmpty || !pathCandidate.startsWith(prefix)) continue;

      final String suffix = pathCandidate.substring(prefix.length);
      if (suffix.isNotEmpty && !suffix.contains("_")) {
        final int? childIndex = int.tryParse(suffix);

        if (childIndex != null) {
          childIndices.add(childIndex);
        }
      }
    }
    childIndices.sort();

    if (childIndices.isNotEmpty) {
      final int maxIndex = childIndices.last;
      final List<Index<I>?> children = List.filled(maxIndex + 1, null);

      for (final int i in childIndices) {
        final String childPath = _path(path, i);
        children[i] = await loadIndex(
          storage: storage,
          type: type,
          colName: colName,
          path: childPath,
        );
      }
      index.children.addAll(children);
    }

    return index;
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

    if (index.points != null) {
      if (!await indexFolder.exists()) {
        await indexFolder.create();
      }

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
  }) async {
    final Index<int>? index = await loadIndex<T, int>(
      storage: storage,
      type: type,
      colName: Key.indexName,
      path: path,
    );
    return index as Key?;
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
