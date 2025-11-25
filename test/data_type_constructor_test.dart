import "dart:convert";

import "package:test/test.dart";

import "fixtures.dart";

void main() {
  group("DataType Constructor Tests", () {
    test("sc field should be initialized in json constructor", () {
      final entity = TestEntity(id: 1, name: "test", value: 42);
      final json = entity.toJson();

      final fromJson = TestEntity.json(json);

      expect(fromJson.sc, isNotNull,
          reason: "sc field should be initialized in json constructor");
      expect(fromJson.sc, equals(testEntityStorageClass),
          reason: "sc field should be set to correct storage class");
    });

    test("sc field should be initialized in string constructor", () {
      final entity = TestEntity(id: 1, name: "test", value: 42);
      final jsonString = jsonEncode(entity.toJson());

      final fromString = TestEntity.string(jsonString);

      expect(fromString.sc, isNotNull,
          reason: "sc field should be initialized in string constructor");
      expect(fromString.sc, equals(testEntityStorageClass),
          reason: "sc field should be set to correct storage class");
    });

    test("sc field should be initialized for nested objects", () {
      final child = TestEntity(id: 2, name: "child", value: 10);
      final parent = TestEntity(id: 1, name: "parent", value: 20, child: child);
      final json = parent.toJson();

      final fromJson = TestEntity.json(json);

      expect(fromJson.sc, isNotNull,
          reason: "parent sc field should be initialized");
      expect(fromJson.child?.sc, isNotNull,
          reason: "nested child sc field should be initialized");
      expect(fromJson.child?.sc, equals(testEntityStorageClass),
          reason: "nested child sc should be correct storage class");
    });

    test("toStorable should work with json constructor", () {
      final entity = TestEntity(id: 1, name: "test", value: 42);
      final json = entity.toJson();

      final fromJson = TestEntity.json(json);

      expect(() => fromJson.toStorable(), returnsNormally,
          reason: "toStorable should work when sc is initialized");

      final storable = fromJson.toStorable();
      expect(storable, isNotEmpty);
    });

    test("toStorable should work with string constructor", () {
      final entity = TestEntity(id: 1, name: "test", value: 42);
      final jsonString = jsonEncode(entity.toJson());

      final fromString = TestEntity.string(jsonString);

      expect(() => fromString.toStorable(), returnsNormally,
          reason: "toStorable should work when sc is initialized");

      final storable = fromString.toStorable();
      expect(storable, isNotEmpty);
    });
  });
}
