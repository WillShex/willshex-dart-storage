//
//  index_extensions.dart
//  storage
//
//  Created by William Shakour (billy1380) on 25 Nov 2024.
//  Copyright © 2024 WillShex Limited. All rights reserved.
//

import "dart:convert";

import "package:fs_shim/fs_shim.dart";

import "index.dart";
import "pair.dart";

extension IndexScanningEx<T> on Index<T> {
  Future<void> scan(bool Function(T item) callback) async {
    if (indexFile == null || childFiles == null) {
      throw StateError(
          "Index not configured for scanning. Use IndexHelper.scanIndex()");
    }

    for (final File file in [indexFile!, ...childFiles!]) {
      final String content = await file.readAsString();
      final List<String> lines = const LineSplitter().convert(content);
      for (final String line in lines) {
        if (line.trim().isEmpty) continue;
        T item = _parseLine<T>(line);
        if (!callback(item)) return;
      }
    }
  }

  T _parseLine<T>(String line) {
    if (T == String) return line as T;
    if (T == int) return int.parse(line) as T;
    if (T == Pair<String, int>) return Pair.fromString<String, int>(line) as T;
    throw UnsupportedError("Type $T not supported");
  }
}
