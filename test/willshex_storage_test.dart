import 'dart:async';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:universal_file/universal_file.dart';
import 'package:willshex_storage/storage.dart';

class Test1Type extends DataType {
  Test1Type({int? id, DateTime? created, bool? deleted})
      : super(sc: T1, id: id, created: created, deleted: deleted) {}

  Test1Type.json(super.json) : super.json() {
    sc = T1;
  }

  Test1Type.string(super.string) : super.string() {
    sc = T1;
  }
}

class Test2Type extends DataType {
  Test2Type() : super(sc: T2);
  Test2Type.json(super.json) : super.json() {
    sc = T2;
  }

  Test2Type.string(super.string) : super.string() {
    sc = T2;
  }
}

class Test3Type extends DataType {
  Test3Type() : super(sc: T3);
  Test3Type.json(super.json) : super.json() {
    sc = T3;
  }

  Test3Type.string(super.string) : super.string() {
    sc = T3;
  }
}

class Test4Type extends DataType {
  Test4Type() : super(sc: T4);
  Test4Type.json(super.json) : super.json() {
    sc = T4;
  }

  Test4Type.string(super.string) : super.string() {
    sc = T4;
  }
}

const Class<Test1Type> T1 = Class<Test1Type>(
  "Test1Type",
  Test1Type.new,
  Test1Type.string,
  Test1Type.json,
);

Test2Type t2() => Test2Type();
const Class<Test2Type> T2 = Class<Test2Type>(
  "Test2Type",
  Test2Type.new,
  Test2Type.string,
  Test2Type.json,
);

Test3Type t3() => Test3Type();
const Class<Test3Type> T3 = Class<Test3Type>(
  "Test3Type",
  Test3Type.new,
  Test3Type.string,
  Test3Type.json,
);

Test4Type t4() => Test4Type();
const Class<Test4Type> T4 = Class<Test4Type>(
  "Test4Type",
  Test4Type.new,
  Test4Type.string,
  Test4Type.json,
);

void main() {
  setupLogging();

  final Logger log = Logger("test:main");

  group("Storage Tests", () {
    late Storage cached, uncached;
    Future<String> path() async => "./data";

    setUpAll(() async {
      Directory output = Directory(await path())
        ..delete(
          recursive: true,
        );

      log.info("Data path ${output.absolute.path}");

      cached = StorageProvider.provide(path).cache(true);

      uncached = StorageProvider.provide(path).cache(false);
    });

    test("Store data with set id", () async {
      expect(await cached.save.entity(Test1Type(id: 1)), 1);
      expect(await cached.save.entity(Test1Type(id: 4)), 4);
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
