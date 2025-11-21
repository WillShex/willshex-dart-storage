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

  final Logger log = Logger("test:main");

  group("Storage Query Tests", () {
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
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 1),
        TestEntity(name: "a", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 2),
        TestEntity(name: "b", value: 3),
      ]);
    });

    test("Test distinct", () async {
      final query = cached.load.type(TE).distinct(true);
      final results = await query.list;
      expect(results.length, 4);
    });

    test("Test group by 'name'", () async {
      final query = cached.load.type(TE).group("name");
      final results = await query.list;
      expect(results.length, 2);
    });

    test("Test group by 'value'", () async {
      final query = cached.load.type(TE).group("value");
      final results = await query.list;
      expect(results.length, 3);
    });

    test("Test group by 'name' and 'value'", () async {
      final query = cached.load.type(TE).group("name").group("value");
      final results = await query.list;
      expect(results.length, 4);
    });
  });
}
