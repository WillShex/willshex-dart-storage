import "package:fs_shim/fs_memory.dart";
import "package:fs_shim/fs_shim.dart" as shim;
import "package:test/test.dart";
import "package:willshex_storage/src/storage/impl/file_system_access.dart"
    as access;
import "package:willshex_storage/src/storage/impl/storage_impl.dart";
import "package:willshex_storage/storage.dart";

import "fixtures.dart";

void main() {
  setupLogging();

  // an in-memory file system drops the trailing slash from a folder path,
  // like the browser one, which the real file system does not
  group("Index location", () {
    late shim.FileSystem original;
    late Storage store;

    setUp(() {
      original = access.fs;
      access.fs = newFileSystemMemory();
      store = StorageProvider.provide(() => "/data/index_location");
    });

    tearDown(() {
      access.fs = original;
    });

    Future<List<String>> typeFolderEntries() async {
      final shim.Directory folder = access.fs.directory(
          (await (store as StorageImpl).ensureFolder("TestEntity")).path);
      return [
        await for (final shim.FileSystemEntity e in folder.list())
          e.path.split("/").last,
      ];
    }

    test("an index is saved inside .index, not next to the records", () async {
      await store.save.entities([
        TestEntity(name: "A", value: 10),
        TestEntity(name: "B", value: 20),
        TestEntity(name: "C", value: 10),
      ]);

      final results = await store.load
          .type(testEntityStorageClass)
          .filter("value", 10)
          .list;
      expect(results.length, 2);

      final List<String> entries = await typeFolderEntries();
      expect(entries, isNot(contains(".indexvalue")));
      expect(entries.where((e) => e.startsWith(".index") && e != ".index"),
          isEmpty);

      final shim.File indexFile = access.fs.file(
          "${(await (store as StorageImpl).ensureFolder("TestEntity")).path}/.index/value");
      expect(await indexFile.exists(), isTrue);
    });

    test("overlapping first queries all see the full result", () async {
      await store.save.entities([
        for (int i = 0; i < 30; i++) TestEntity(name: "N$i", value: i % 3),
      ]);

      final results = await Future.wait([
        for (int i = 0; i < 20; i++)
          store.load.type(testEntityStorageClass).filter("value", 1).list,
      ]);

      expect(results.map((r) => r.length), everyElement(10));
      expect((store as StorageImpl).indexBuilds, isEmpty);
    });
  });
}
