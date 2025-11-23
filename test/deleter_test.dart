import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void main() {
  setupLogging();

  final Logger log = Logger("test:deleter");

  group("Deleter Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/deleter";

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
        TestEntity(name: "A", value: 10),
        TestEntity(name: "B", value: 20),
        TestEntity(name: "C", value: 30),
      ]);
    });

    test("Deleter Entities", () async {
      final toDelete = await cached.load.type(TE).filter("name", "A").list;
      await cached.delete.entities(toDelete);

      final count = await cached.load.type(TE).count;
      expect(count, 2);

      final deleted = await cached.load.type(TE).filter("name", "A").list;
      expect(deleted, isEmpty);
    });

    test("Deleter Type IDs", () async {
      final toDelete = await cached.load.type(TE).filter("name", "B").list;
      final ids = toDelete.map((e) => e.id!).toList();
      await cached.delete.type(TE).ids(ids);

      final count = await cached.load.type(TE).count;
      expect(count, 2);
    });
  });
}
