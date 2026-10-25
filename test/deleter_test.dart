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

    test("A deleted entity is no longer loaded by id from the cache", () async {
      final entity =
          (await cached.load.testEntity.filter("name", "C").list).single;
      expect(await cached.load.testEntity.id(entity.id!), isNotNull);

      await cached.delete.entity(entity);

      expect(await cached.load.testEntity.id(entity.id!), isNull);
      expect(await cached.load.testEntity.ids([entity.id!]), isEmpty);
    });

    test("Deleter All (Preserves Auto Increment)", () async {
      await cached.delete.testEntity.all();

      final count = await cached.load.testEntity.count;
      expect(count, 0);

      TestEntity newItem = TestEntity(name: "D", value: 40);
      await cached.save.entity(newItem);
      expect(newItem.id, 4);
    });

    test("Deleter Drop (Resets Auto Increment)", () async {
      await cached.delete.testEntity.drop();

      final count = await cached.load.testEntity.count;
      expect(count, 0);

      TestEntity newItem = TestEntity(name: "E", value: 50);
      await cached.save.entity(newItem);
      expect(newItem.id, 1);
    });
  });

  group("Explicit ids", () {
    late Storage store;
    Future<String> path() async => "./data/explicit_ids";

    setUp(() async {
      Directory output = Directory(await path());
      if (await output.exists()) {
        await output.delete(recursive: true);
      }

      store = StorageProvider.provide(path).cache(true);
    });

    test("a new entity does not take the id of an imported one", () async {
      await store.save.entities([
        TestEntity(id: 5, name: "five", value: 1),
        TestEntity(id: 9, name: "nine", value: 2),
      ]);

      final added = TestEntity(name: "new", value: 3);
      await store.save.entity(added);

      expect(added.id, 10);
      expect((await store.load.testEntity.id(9))!.name, "nine");
      expect(await store.load.testEntity.count, 3);
    });

    test("a counter left on a used id, as older stores have, is skipped",
        () async {
      await store.save.entity(TestEntity(id: 7, name: "seven", value: 1));
      await File("${await path()}/TestEntity/_.autoinc").writeAsString("7");

      final added = TestEntity(name: "new", value: 2);
      await store.save.entity(added);

      expect(added.id, 8);
      expect((await store.load.testEntity.id(7))!.name, "seven");
    });

    test("ids keep counting up from one when nothing is imported", () async {
      final first = TestEntity(name: "a", value: 1);
      final second = TestEntity(name: "b", value: 2);
      await store.save.entities([first, second]);

      expect([first.id, second.id], [1, 2]);
    });
  });
}
