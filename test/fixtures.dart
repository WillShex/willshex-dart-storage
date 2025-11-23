library fixtures;

import 'package:willshex_storage/storage.dart';

part 'fixtures.sc.dart';

class TestEntity extends DataType {
  String? name;
  int? value;
  List<String>? tags;
  TestEntity? child;

  TestEntity({
    int? id,
    this.name,
    this.value,
    this.tags,
    this.child,
  }) : super(sc: testEntityStorageClass, id: id);

  TestEntity.json(super.json) : super.json() {
    sc = testEntityStorageClass;
  }

  TestEntity.string(super.string) : super.string() {
    sc = testEntityStorageClass;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json["name"];
    value = json["value"];
    if (json["tags"] != null) {
      tags = List<String>.from(json["tags"]);
    }
    if (json["child"] != null) {
      child = TestEntity.json(json["child"]);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["name"] = name;
    json["value"] = value;
    if (tags != null) {
      json["tags"] = tags;
    }
    if (child != null) {
      json["child"] = child!.toJson();
    }
    return json;
  }
}

class SimpleEntity extends DataType {
  SimpleEntity({int? id, DateTime? created, bool? deleted})
      : super(
            sc: simpleEntityStorageClass,
            id: id,
            created: created,
            deleted: deleted);

  SimpleEntity.json(super.json) : super.json() {
    sc = simpleEntityStorageClass;
  }

  SimpleEntity.string(super.string) : super.string() {
    sc = simpleEntityStorageClass;
  }
}

class Test2Type extends DataType {
  Test2Type() : super(sc: test2TypeStorageClass);
  Test2Type.json(super.json) : super.json() {
    sc = test2TypeStorageClass;
  }

  Test2Type.string(super.string) : super.string() {
    sc = test2TypeStorageClass;
  }
}

class Test3Type extends DataType {
  Test3Type() : super(sc: test3TypeStorageClass);
  Test3Type.json(super.json) : super.json() {
    sc = test3TypeStorageClass;
  }

  Test3Type.string(super.string) : super.string() {
    sc = test3TypeStorageClass;
  }
}

class Test4Type extends DataType {
  Test4Type() : super(sc: test4TypeStorageClass);
  Test4Type.json(super.json) : super.json() {
    sc = test4TypeStorageClass;
  }

  Test4Type.string(super.string) : super.string() {
    sc = test4TypeStorageClass;
  }
}
