import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void main() {
  setupLogging();

  final Logger log = Logger("test:query");

  group("Query Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/query";

    setUp(() async {
      Directory output = Directory(await path());
      if (output.existsSync()) {
        output.deleteSync(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);

      // Add test data
      await cached.save.entities([
        TestEntity(name: "A", value: 10, tags: ["one", "two"]),
        TestEntity(name: "B", value: 20, tags: ["two", "three"]),
        TestEntity(name: "C", value: 30, tags: ["three", "four"]),
        TestEntity(
            name: "D",
            value: 40,
            tags: ["four", "five"],
            child: TestEntity(id: 100, name: "DA", value: 1)),
        TestEntity(
            name: "E",
            value: 50,
            tags: ["five", "six"],
            child: TestEntity(id: 101, name: "EA", value: 2)),
      ]);
    });

    test("Query Filter Equals", () async {
      final query = cached.load.testEntity.filter("name", "C");
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "C");
    });

    test("Query Filter Greater Than", () async {
      final query = cached.load.testEntity.filter("value >", 30);
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["D", "E"]));
    });

    test("Query Limit and Offset", () async {
      final query = cached.load.testEntity.order("value").limit(2).offset(1);
      final results = await query.list;
      expect(results.length, 2);
      expect(results[0].name, "B");
      expect(results[1].name, "C");
    });

    test("Query Order Descending", () async {
      final query = cached.load.testEntity.order("-value");
      final results = await query.list;
      expect(results.first.value, 50);
      expect(results.last.value, 10);
    });

    test("Query Order String Ascending", () async {
      final query = cached.load.testEntity.order("name");
      final results = await query.list;
      expect(results.first.name, "A");
      expect(results.last.name, "E");
    });

    test("Query Reverse", () async {
      final query = cached.load.testEntity.order("value").reverse();
      final results = await query.list;
      expect(results.first.value, 50);
    });

    test("Query Count", () async {
      final count = await cached.load.testEntity.count;
      expect(count, 5);
    });

    test("Query Filter Greater Than (String)", () async {
      final query = cached.load.testEntity.filter("name >", "C");
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["D", "E"]));
    });

    test("Query Filter Greater Than (Array)", () async {
      final query = cached.load.testEntity.filter("tags >", ["one"]);
      final results = await query.list;
      expect(results.length, 5);
    });

    test("Query Filter Greater Than (Type)", () async {
      final query = cached.load.testEntity.filter("child >", TestEntity(id: 100));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "E");
    });

    test("Query Filter Less Than (String)", () async {
      final query = cached.load.testEntity.filter("name <", "C");
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["A", "B"]));
    });

    test("Query Filter Less Than (int)", () async {
      final query = cached.load.testEntity.filter("value <", 30);
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.value), containsAll([10, 20]));
    });

    test("Query Filter Equals (String)", () async {
      final query = cached.load.testEntity.filter("name", "C");
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "C");
    });

    test("Query Filter Equals (int)", () async {
      final query = cached.load.testEntity.filter("value", 30);
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.value, 30);
    });

    test("Query Filter Equals (Array)", () async {
      final query = cached.load.testEntity.filter("tags", ["one", "two"]);
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "A");
    });

    test("Query Filter Less Than (Array)", () async {
      final query =
          cached.load.testEntity.filter("tags <", ["one", "two", "three"]);
      final results = await query.list;
      expect(results.length, 5);
    });

    test("Query Filter Less Than (Type)", () async {
      final query = cached.load.testEntity.filter("child <", TestEntity(id: 101));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "D");
    });

    test("Query Filter Equals (Type)", () async {
      final query = cached.load.testEntity.filter("child", TestEntity(id: 100));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "D");
    });

    test("Query Filter In (String)", () async {
      final query = cached.load.testEntity.filter("name in", ["A", "C", "E"]);
      final results = await query.list;
      expect(results.length, 3);
      expect(results.map((e) => e.name), containsAll(["A", "C", "E"]));
    });

    test("Test distinct", () async {
      // Clear existing data to ensure clean state for this test
      // Or just append? The setUp adds 5 entities.
      // Let's add specific data for these tests.
      await cached.save.entities([
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 3),
      ]);

      // Filter by name "a" or "b" to exclude the setUp data (A, B, C, D, E)
      // Note: "a" != "A" (case sensitive usually)
      final query =
          cached.load.testEntity.filter("name in", ["a", "b"]).distinct(true);
      final results = await query.list;
      expect(results.length, 4);
    });

    test("Test group by 'name'", () async {
      // Ensure data exists (it persists across tests in the same file if not cleared,
      // but setUp runs before each test and clears directory?
      // YES. setUp deletes the directory!
      // So we need to re-add the data for EACH test or move it to setUp.

      await cached.save.entities([
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 3),
      ]);

      final query =
          cached.load.testEntity.filter("name in", ["a", "b"]).group("name");
      final results = await query.list;
      expect(results.length, 2);
    });

    test("Test group by 'value'", () async {
      await cached.save.entities([
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 3),
      ]);

      final query =
          cached.load.testEntity.filter("name in", ["a", "b"]).group("value");
      final results = await query.list;
      expect(results.length, 3);
    });

    test("Test group by 'name' and 'value'", () async {
      await cached.save.entities([
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 3),
      ]);

      final query = cached.load
          .testEntity
          .filter("name in", ["a", "b"])
          .group("name")
          .group("value");
      final results = await query.list;
      expect(results.length, 4);
    });
  });
}