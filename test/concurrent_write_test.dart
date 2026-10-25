import "dart:convert";

import "package:fs_shim/fs_memory.dart";
import "package:fs_shim/fs_shim.dart" as shim;
import "package:test/test.dart";
import "package:willshex_storage/src/storage/impl/file_system_access.dart"
    as access;
import "package:willshex_storage/storage.dart";

import "fixtures.dart";

void main() {
  setupLogging();

  const int rounds = 100;

  Future<void> overlappingUpdates(
    Storage store,
    Future<String> Function(String name) readRaw,
  ) async {
    TestEntity seed = TestEntity(name: "seed", value: 1);
    await store.save.entity(seed);

    for (int i = 0; i < rounds; i++) {
      // a long value and a short one written to the same record at once
      TestEntity longer = TestEntity(id: seed.id, name: "L" * 200, value: 1);
      TestEntity shorter = TestEntity(id: seed.id, name: "S", value: 2);

      await Future.wait([
        store.save.entity(longer),
        store.save.entity(shorter),
      ]);

      String raw = await readRaw("${seed.id}.json");

      expect(() => jsonDecode(raw), returnsNormally,
          reason: "round $i left a corrupt record: $raw");
    }
  }

  group("Concurrent writes", () {
    test("overlapping updates never leave a corrupt record", () async {
      Directory output = Directory("./data/concurrent_write");
      if (await output.exists()) {
        await output.delete(recursive: true);
      }

      Storage store = StorageProvider.provide(() async => output.path);

      await overlappingUpdates(store,
          (name) => File("${output.path}/TestEntity/$name").readAsString());
    });

    test("a read during an update always sees a whole record", () async {
      Directory output = Directory("./data/concurrent_write_read");
      if (await output.exists()) {
        await output.delete(recursive: true);
      }

      Storage store = StorageProvider.provide(() async => output.path);

      TestEntity seed = TestEntity(name: "seed", value: 1);
      await store.save.entity(seed);

      for (int i = 0; i < rounds; i++) {
        TestEntity longer = TestEntity(id: seed.id, name: "L" * 200, value: 1);
        TestEntity shorter = TestEntity(id: seed.id, name: "S", value: 2);

        List<Object?> results = await Future.wait<Object?>([
          store.save.entity(longer),
          store.load.type(testEntityStorageClass).id(seed.id!),
          store.save.entity(shorter),
          store.load.type(testEntityStorageClass).id(seed.id!),
          store.load.type(testEntityStorageClass).list,
        ]);

        expect((results[1] as TestEntity?)?.id, seed.id);
        expect((results[3] as TestEntity?)?.id, seed.id);
        expect((results[4] as List<TestEntity>).length, 1);
      }
    });

    test("the same holds on the in-memory file system", () async {
      shim.FileSystem original = access.fs;
      access.fs = newFileSystemMemory();

      try {
        Storage store =
            StorageProvider.provide(() async => "/data/concurrent_write");

        await overlappingUpdates(
            store,
            (name) => access.fs
                .file("/data/concurrent_write/TestEntity/$name")
                .readAsString());
      } finally {
        access.fs = original;
      }
    });
  });
}
