import "dart:async";

import "package:logging/logging.dart";
import "package:test/test.dart";
import "package:universal_file/universal_file.dart";
import "package:willshex_storage/storage.dart";

import "fixtures.dart";

void main() {
  setupLogging();

  final Logger log = Logger("test:deleter");

  group("Deleter Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/deleter";

    setUp(() async {
      Directory output = Directory(await path());
      if (await output.exists()) {
        await output.delete(
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
      final toDelete = await cached.load.testEntity.filter("name", "A").list;
      await cached.delete.entities(toDelete);

      final count = await cached.load.testEntity.count;
      expect(count, 2);

      final deleted = await cached.load.testEntity.filter("name", "A").list;
      expect(deleted, isEmpty);
    });

    test("Deleter Type IDs", () async {
      final toDelete = await cached.load.testEntity.filter("name", "B").list;
      final ids = toDelete.map((e) => e.id!).toList();
      await cached.delete.testEntity.ids(ids);

      final count = await cached.load.testEntity.count;
      expect(count, 2);
    });
  });
}
