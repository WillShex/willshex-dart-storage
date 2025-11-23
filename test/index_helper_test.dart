import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/src/storage/impl/helper/index_helper.dart';
import 'package:willshex_storage/src/storage/impl/index/index.dart';
import 'package:willshex_storage/src/storage/impl/index/key.dart';
import 'package:willshex_storage/src/storage/impl/storage_impl.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void main() {
  setupLogging();

  final Logger log = Logger("test:index_helper");

  group("IndexHelper Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/index_helper";

    setUp(() async {
      Directory output = Directory(await path());
      if (output.existsSync()) {
        output.deleteSync(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);
    });

    test("Save and Load Index", () async {
      final index = Index<String>("testIndex");
      index.points = ["a", "b", "c"];

      await IndexHelper.saveIndex(
        storage: cached as StorageImpl,
        index: index,
        type: testEntityStorageClass,
        colName: "testIndex",
      );

      final loadedIndex = await IndexHelper.loadIndex<TestEntity, String>(
        storage: cached as StorageImpl,
        type: testEntityStorageClass,
        colName: "testIndex",
      );

      expect(loadedIndex, isNotNull);
      expect(loadedIndex!.points, orderedEquals(["a", "b", "c"]));
    });

    test("Save and Load Index with various types", () async {
      final indexInt = Index<int>("testIndexInt");
      indexInt.points = [1, 2, 3];
      await IndexHelper.saveIndex(
        storage: cached as StorageImpl,
        index: indexInt,
        type: testEntityStorageClass,
        colName: "testIndexInt",
      );
      final loadedInt = await IndexHelper.loadIndex<TestEntity, int>(
        storage: cached as StorageImpl,
        type: testEntityStorageClass,
        colName: "testIndexInt",
      );
      expect(loadedInt!.points, orderedEquals([1, 2, 3]));

      final indexDouble = Index<double>("testIndexDouble");
      indexDouble.points = [1.1, 2.2, 3.3];
      await IndexHelper.saveIndex(
        storage: cached as StorageImpl,
        index: indexDouble,
        type: testEntityStorageClass,
        colName: "testIndexDouble",
      );
      final loadedDouble = await IndexHelper.loadIndex<TestEntity, double>(
        storage: cached as StorageImpl,
        type: testEntityStorageClass,
        colName: "testIndexDouble",
      );
      expect(loadedDouble!.points, orderedEquals([1.1, 2.2, 3.3]));

      final indexBool = Index<bool>("testIndexBool");
      indexBool.points = [true, false, true];
      await IndexHelper.saveIndex(
        storage: cached as StorageImpl,
        index: indexBool,
        type: testEntityStorageClass,
        colName: "testIndexBool",
      );
      final loadedBool = await IndexHelper.loadIndex<TestEntity, bool>(
        storage: cached as StorageImpl,
        type: testEntityStorageClass,
        colName: "testIndexBool",
      );
      expect(loadedBool!.points, orderedEquals([true, false, true]));
    });

    test("Save and Load Key", () async {
      final key = Key.createKey();
      key.points = [1, 2, 3];

      await IndexHelper.saveKey(
        storage: cached as StorageImpl,
        key: key,
        type: testEntityStorageClass,
      );

      final loadedKey = await IndexHelper.loadKey<TestEntity>(
        storage: cached as StorageImpl,
        type: testEntityStorageClass,
        colName: Key.indexName,
      );

      expect(loadedKey, isNotNull);
      expect(loadedKey!.points, orderedEquals([1, 2, 3]));
    });

    test("Weigh", () {
      final weight = IndexHelper.weigh("abc");
      expect(weight, greaterThan(0));
    });
  });
}