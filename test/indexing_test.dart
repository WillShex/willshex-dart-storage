import "dart:async";

import "package:logging/logging.dart";
import "package:test/test.dart";
import "package:universal_file/universal_file.dart";
import "package:willshex_storage/src/storage/impl/storage_impl.dart";
import "package:willshex_storage/storage.dart";

import "fixtures.dart";

void main() {
  setupLogging();

  final Logger log = Logger("test:indexing");

  group("Indexing Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/indexing";

    setUp(() async {
      Directory output = Directory(await path());
      if (await output.exists()) {
        await output.delete(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);
    });

    test("Dynamic Index Creation and Usage", () async {
      await cached.save.entities([
        TestEntity(name: "A", value: 10),
        TestEntity(name: "B", value: 20),
        TestEntity(name: "C", value: 10),
      ]);

      var query = cached.load.type(testEntityStorageClass).filter("value", 10);
      var results = await query.list;

      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["A", "C"]));

      Directory indexFolder = Directory(
          "${(await (cached as StorageImpl).ensureFolder("TestEntity")).path}/.index/");
      File indexFile = File("${indexFolder.path}/value");
      expect(await indexFile.exists(), isTrue);

      results = await query.list;
      expect(results.length, 2);

      await cached.save.entities([
        TestEntity(name: "D", value: 10),
      ]);

      results = await query.list;
      expect(results.length, 3);
      expect(results.map((e) => e.name), containsAll(["A", "C", "D"]));

      var d = results.firstWhere((e) => e.name == "D");
      await cached.delete.type(testEntityStorageClass).ids([d.id!]);

      results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["A", "C"]));
    });

    test("String Indexing", () async {
      await cached.save.entities([
        TestEntity(name: "Alice", value: 1),
        TestEntity(name: "Bob", value: 2),
        TestEntity(name: "Charlie", value: 3),
      ]);

      var query =
          cached.load.type(testEntityStorageClass).filter("name", "Bob");
      var results = await query.list;

      expect(results.length, 1);
      expect(results.first.name, "Bob");
      Directory indexFolder = Directory(
          "${(await (cached as StorageImpl).ensureFolder("TestEntity")).path}/.index/");
      File indexFile = File("${indexFolder.path}/name");
      expect(await indexFile.exists(), isTrue);
    });

    test("ID Indexing (Key)", () async {
      await cached.save.entities([
        TestEntity(name: "X", value: 1),
      ]);
      var query = cached.load.type(testEntityStorageClass).filter("id", 1);
      var results = await query.list;

      expect(results.length, 1);
      expect(results.first.name, "X");
      Directory indexFolder = Directory(
          "${(await (cached as StorageImpl).ensureFolder("TestEntity")).path}/.index/");
      File indexFile = File("${indexFolder.path}/id");
      expect(await indexFile.exists(), isTrue);
    });

    test("IN Operator Indexing", () async {
      await cached.save.entities([
        TestEntity(name: "a", value: 1),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "c", value: 3),
      ]);

      var query = cached.load
          .type(testEntityStorageClass)
          .filter("name in", ["a", "b"]);
      var results = await query.list;

      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["a", "b"]));
    });

    test("Multiple Index Updates (Directory Creation)", () async {
      await cached.save.entities([
        TestEntity(name: "test1", value: 10),
        TestEntity(name: "test2", value: 20),
      ]);

      await cached.load
          .type(testEntityStorageClass)
          .filter("name", "test1")
          .list;
      await cached.load.type(testEntityStorageClass).filter("value", 10).list;

      var entities = await cached.load.type(testEntityStorageClass).list;
      await cached.delete
          .type(testEntityStorageClass)
          .ids(entities.map((e) => e.id!));

      var results = await cached.load.type(testEntityStorageClass).list;
      expect(results.length, 0);
    });

    test("Saving a changed value drops the old index entry", () async {
      final saved = await cached.save.entity(TestEntity(name: "A", value: 10));

      var results = await cached.load
          .type(testEntityStorageClass)
          .filter("value", 10)
          .list;
      expect(results.length, 1);

      final entity = results.single..value = 20;
      await cached.save.entity(entity);

      final indexFile = File(
          "${(await (cached as StorageImpl).ensureFolder("TestEntity")).path}/.index/value");
      final points = (await indexFile.readAsString()).split("\n");
      expect(points, isNot(contains("10:$saved")));
      expect(points, contains("20:$saved"));

      results = await cached.load
          .type(testEntityStorageClass)
          .filter("value", 10)
          .list;
      expect(results, isEmpty);

      results = await cached.load
          .type(testEntityStorageClass)
          .filter("value", 20)
          .list;
      expect(results.length, 1);
    });

    test("A stale index entry never returns a record that no longer matches",
        () async {
      final uncached = StorageProvider.provide(path);

      final id = await uncached.save.entity(TestEntity(name: "A", value: 10));
      await uncached.save.entity(TestEntity(name: "B", value: 20));

      var results = await uncached.load
          .type(testEntityStorageClass)
          .filter("value", 10)
          .list;
      expect(results.map((e) => e.name), ["A"]);

      final record = File(
          "${(await (uncached as StorageImpl).ensureFolder("TestEntity")).path}/$id.json");
      await record.writeAsString(
          (TestEntity(id: id, name: "A", value: 30)).toStorable());

      results = await uncached.load
          .type(testEntityStorageClass)
          .filter("value", 10)
          .list;
      expect(results, isEmpty);
    });
  });
}

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print("${rec.level.name}: ${rec.time}: ${rec.message}");
  });
}
