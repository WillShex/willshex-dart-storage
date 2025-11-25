import "package:test/test.dart";
import "package:willshex_storage/src/storage/impl/index/key.dart";
import "package:willshex_storage/src/storage/impl/index/key_region.dart"; // Import KeyRegion

void main() {
  group("Key Tests", () {
    test("Key.createKey default", () {
      final key = Key.createKey();
      expect(key, isA<Key>());
      expect(key.name, "id");
    });

    test("Key.createKey with custom capacity", () {
      final key = Key.createKey(100);
      expect(key, isA<Key>());
      expect(key.name, "id");
    });

    test("KeyRegion bounds in Key.createKey", () {
      final key = Key.createKey();
      expect(key, isA<Key>());
      expect(key.name, "id");
    });

    test("KeyRegion bounds", () {
      final defaultRegion = KeyRegion(0, Key.max);
      expect(defaultRegion.start, 0);
      expect(defaultRegion.end, Key.max);
      expect(defaultRegion.contains(0), isTrue);
      expect(defaultRegion.contains(Key.max - 1), isTrue);
      expect(defaultRegion.contains(Key.max), isFalse);
    });
  });
}
