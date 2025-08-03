import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

class Test1Type extends DataType {
  String? a;
  int? b;

  Test1Type({int? id, DateTime? created, bool? deleted, this.a, this.b})
      : super(sc: T1, id: id, created: created, deleted: deleted) {}

  Test1Type.json(super.json) : super.json() {
    sc = T1;
  }

  Test1Type.string(super.string) : super.string() {
    sc = T1;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    a = json["a"];
    b = json["b"];
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["a"] = a;
    json["b"] = b;
    return json;
  }
}

const Class<Test1Type> T1 = Class<Test1Type>(
  "Test1Type",
  Test1Type.new,
  Test1Type.string,
  Test1Type.json,
);

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
    Future<String> path() async => "./data_query";

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
        Test1Type(a: "a", b: 1),
        Test1Type(a: "a", b: 1),
        Test1Type(a: "a", b: 2),
        Test1Type(a: "b", b: 2),
        Test1Type(a: "b", b: 2),
        Test1Type(a: "b", b: 3),
      ]);
    });

    test("Test distinct", () async {
      final query = cached.load.type(T1).distinct(true);
      final results = await query.list;
      expect(results.length, 4);
    });

    test("Test group by 'a'", () async {
      final query = cached.load.type(T1).group("a");
      final results = await query.list;
      expect(results.length, 2);
    });

    test("Test group by 'b'", () async {
      final query = cached.load.type(T1).group("b");
      final results = await query.list;
      expect(results.length, 3);
    });

    test("Test group by 'a' and 'b'", () async {
      final query = cached.load.type(T1).group("a").group("b");
      final results = await query.list;
      expect(results.length, 4);
    });
  });
}
