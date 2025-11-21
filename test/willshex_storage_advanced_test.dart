import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('[${rec.level.name}] ${rec.time}: ${rec.message}');
  });
}

void main() {
  setupLogging();

  final Logger log = Logger("test:advanced");

  group("Advanced Storage Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/advanced";

    setUp(() async {
      Directory output = Directory(await path());
      if (output.existsSync()) {
        output.deleteSync(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);

      // Add initial data
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
      final query = cached.load.type(TE).filter("name", "C");
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "C");
    });

    test("Query Filter Greater Than", () async {
      final query = cached.load.type(TE).filter("value >", 30);
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["D", "E"]));
    });

    test("Query Limit and Offset", () async {
      final query = cached.load.type(TE).order("value").limit(2).offset(1);
      final results = await query.list;
      expect(results.length, 2);
      expect(results[0].name, "B");
      expect(results[1].name, "C");
    });

    test("Query Order Descending", () async {
      final query = cached.load.type(TE).order("-value");
      final results = await query.list;
      expect(results.first.value, 50);
      expect(results.last.value, 10);
    });

    test("Query Order String Ascending", () async {
      final query = cached.load.type(TE).order("name");
      final results = await query.list;
      expect(results.first.name, "A");
      expect(results.last.name, "E");
    });

    test("Query Reverse", () async {
      final query = cached.load.type(TE).order("value").reverse();
      final results = await query.list;
      expect(results.first.value, 50);
    });

    test("Query Count", () async {
      final count = await cached.load.type(TE).count;
      expect(count, 5);
    });

    test("Deleter Entities", () async {
      final toDelete = await cached.load.type(TE).filter("name", "A").list;
      await cached.delete.entities(toDelete);

      final count = await cached.load.type(TE).count;
      expect(count, 4);

      final deleted = await cached.load.type(TE).filter("name", "A").list;
      expect(deleted, isEmpty);
    });

    test("Deleter Type IDs", () async {
      final toDelete = await cached.load.type(TE).filter("name", "B").list;
      final ids = toDelete.map((e) => e.id!).toList();
      await cached.delete.type(TE).ids(ids);

      final count = await cached.load.type(TE).count;
      expect(count, 4);
    });

    test("Query Filter Greater Than (String)", () async {
      final query = cached.load.type(TE).filter("name >", "C");
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["D", "E"]));
    });

    test("Query Filter Greater Than (Array)", () async {
      // Assuming array comparison checks length or lexicographical order?
      // Based on QueryHelper.compareArrays:
      // if (a1.length != a2.length) return a1.length > a2.length ? 1 : -1;
      // So it compares length first.
      // "three", "four" (length 2) > "one" (length 1)
      final query = cached.load.type(TE).filter("tags >", ["one"]);
      final results = await query.list;
      // All entities have tags length 2, except maybe none?
      // Wait, ["one"] has length 1. All our tags have length 2.
      // So all should be greater than ["one"].
      expect(results.length, 5);
    });

    test("Query Filter Greater Than (Type)", () async {
      // Comparing TestEntity objects by ID.
      // Child of D has ID 100. Child of E has ID 101.
      // We want entities where child > TestEntity(id: 100).
      // Should match E.
      final query = cached.load.type(TE).filter("child >", TestEntity(id: 100));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "E");
    });

    test("Query Filter Less Than (String)", () async {
      final query = cached.load.type(TE).filter("name <", "C");
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.name), containsAll(["A", "B"]));
    });

    test("Query Filter Less Than (int)", () async {
      final query = cached.load.type(TE).filter("value <", 30);
      final results = await query.list;
      expect(results.length, 2);
      expect(results.map((e) => e.value), containsAll([10, 20]));
    });

    test("Query Filter Equals (String)", () async {
      final query = cached.load.type(TE).filter("name", "C");
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "C");
    });

    test("Query Filter Equals (int)", () async {
      final query = cached.load.type(TE).filter("value", 30);
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.value, 30);
    });

    test("Query Filter Equals (Array)", () async {
      final query = cached.load.type(TE).filter("tags", ["one", "two"]);
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "A");
    });
    
    test("Query Filter Less Than (Array)", () async {
      // ["five", "six"] (length 2) < ["one", "two", "three"] (length 3)
      final query = cached.load.type(TE).filter("tags <", ["one", "two", "three"]);
      final results = await query.list;
      expect(results.length, 5);
    });

    test("Query Filter Less Than (Type)", () async {
      // Child of D has ID 100. Child of E has ID 101.
      // We want entities where child < TestEntity(id: 101).
      // Should match D.
      final query = cached.load.type(TE).filter("child <", TestEntity(id: 101));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "D");
    });

    test("Query Filter Equals (Type)", () async {
      final query = cached.load.type(TE).filter("child", TestEntity(id: 100));
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "D");
    });
    
    test("Query Filter In (String)", () async {
      final query = cached.load.type(TE).filter("name in", ["A", "C", "E"]);
      final results = await query.list;
      expect(results.length, 3);
      expect(results.map((e) => e.name), containsAll(["A", "C", "E"]));
    });
  });
}
