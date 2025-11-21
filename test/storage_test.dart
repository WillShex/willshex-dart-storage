import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void main() {
  setupLogging();

  final Logger log = Logger("test:storage");

  group("Storage Tests", () {
    late Storage cached, uncached;
    Future<String> path() async => "./data/storage";

    setUpAll(() async {
      Directory output = Directory(await path());
      if (output.existsSync()) {
        output.deleteSync(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);

      uncached = StorageProvider.provide(path).cache(false);
    });

    test("Store data with set id", () async {
      expect(await cached.save.entity(SimpleEntity(id: 1)), 1);
      expect(await cached.save.entity(SimpleEntity(id: 4)), 4);
    });

    test("Store data with unset ids (auto-increment)", () async {
      expect(await cached.save.entity(Test2Type()), 1);
      expect(await cached.save.entity(Test2Type()), 2);
    });

    test("Read object (cached)", () async {
      final Test3Type saved = Test3Type();
      expect(await cached.save.entity(saved), 1);
      expect(await cached.load.id(T3, 1), saved);
    });

    test("Read object (uncached)", () async {
      int id = 3;
      final Test4Type saved = Test4Type()..id = id;
      expect(await uncached.save.entity(saved), id);

      Test4Type loaded;
      expect((loaded = (await uncached.load.type(T4).id(id))!).id, saved.id);
      expect(false, saved == loaded);
    });
  });
}

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('[${rec.level.name}] ${rec.time}: ${rec.message}');
  });
}
