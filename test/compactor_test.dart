import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

import 'fixtures.dart';

void main() {
  setupLogging();

  final Logger log = Logger("test:compactor");

  group("Compactor Tests", () {
    late Storage cached;
    Future<String> path() async => "./data/compactor";

    setUp(() async {
      Directory output = Directory(await path());
      if (output.existsSync()) {
        output.deleteSync(
          recursive: true,
        );
      }

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);
    });

    test("Compactor Type", () async {
      // Just ensure it doesn't throw
      await cached.compact.testEntity;
    });
  });
}
