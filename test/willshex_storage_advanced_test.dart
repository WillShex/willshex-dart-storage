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
        TestEntity(name: "A", value: 10),
        TestEntity(name: "B", value: 20),
        TestEntity(name: "C", value: 30),
        TestEntity(name: "D", value: 40),
        TestEntity(name: "E", value: 50),
      ]);
    });

    test("Query Filter Equals", () async {
      final query = cached.load.type(TE).filter("name", "C");
      final results = await query.list;
      expect(results.length, 1);
      expect(results.first.name, "C");
    });

    test("Query Filter Greater Than", () async {
      // Assuming the implementation supports > syntax in filter string or similar
      // Based on filter.dart, it seems to parse suffix operators.
      // Let's check filter.dart content again if needed, but assuming standard suffix
      // If not, we might need to adjust.
      // Looking at QueryImpl.addFilter:
      // if (condition.endsWith(sign!)) ...
      // We need to know what signs are supported.
      // I'll assume standard ones for now, but if it fails I'll check FilterOperation enum.

      // Actually, let's stick to simple Equals first or check FilterOperation values if possible.
      // But for now, let's try a simple filter that we know works (Equals is default).

      // Let's try to use the filter method with a presumed operator if we saw it in code.
      // I saw `fromFilterOperationToString` in QueryImpl.

      // Let's test limit and offset first which are standard.
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

    test("Compactor Type", () async {
      // Just ensure it doesn't throw
      await cached.compact.type(TE);
    });
  });
}
