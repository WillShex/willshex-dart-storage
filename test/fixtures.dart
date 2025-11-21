library fixtures;

import 'package:willshex_storage/storage.dart';

class TestEntity extends DataType {
  String? name;
  int? value;

  TestEntity({int? id, this.name, this.value}) : super(sc: TE, id: id);

  TestEntity.json(super.json) : super.json() {
    sc = TE;
  }

  TestEntity.string(super.string) : super.string() {
    sc = TE;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json["name"];
    value = json["value"];
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["name"] = name;
    json["value"] = value;
    return json;
  }
}

const Class<TestEntity> TE = Class<TestEntity>(
  "TestEntity",
  TestEntity.new,
  TestEntity.string,
  TestEntity.json,
);

class SimpleEntity extends DataType {
  SimpleEntity({int? id, DateTime? created, bool? deleted})
      : super(sc: SE, id: id, created: created, deleted: deleted);

  SimpleEntity.json(super.json) : super.json() {
    sc = SE;
  }

  SimpleEntity.string(super.string) : super.string() {
    sc = SE;
  }
}

const Class<SimpleEntity> SE = Class<SimpleEntity>(
  "SimpleEntity",
  SimpleEntity.new,
  SimpleEntity.string,
  SimpleEntity.json,
);

class Test2Type extends DataType {
  Test2Type() : super(sc: T2);
  Test2Type.json(super.json) : super.json() {
    sc = T2;
  }

  Test2Type.string(super.string) : super.string() {
    sc = T2;
  }
}

const Class<Test2Type> T2 = Class<Test2Type>(
  "Test2Type",
  Test2Type.new,
  Test2Type.string,
  Test2Type.json,
);

class Test3Type extends DataType {
  Test3Type() : super(sc: T3);
  Test3Type.json(super.json) : super.json() {
    sc = T3;
  }

  Test3Type.string(super.string) : super.string() {
    sc = T3;
  }
}

const Class<Test3Type> T3 = Class<Test3Type>(
  "Test3Type",
  Test3Type.new,
  Test3Type.string,
  Test3Type.json,
);

class Test4Type extends DataType {
  Test4Type() : super(sc: T4);
  Test4Type.json(super.json) : super.json() {
    sc = T4;
  }

  Test4Type.string(super.string) : super.string() {
    sc = T4;
  }
}

const Class<Test4Type> T4 = Class<Test4Type>(
  "Test4Type",
  Test4Type.new,
  Test4Type.string,
  Test4Type.json,
);
