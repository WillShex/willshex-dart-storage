import 'package:test/test.dart';
import 'package:willshex_storage/src/storage/impl/index/index.dart';

import 'mocks.dart';

void main() {
  group("Index Tests", () {
    test("Index constructor", () {
      final index = Index<String>("testIndex");
      expect(index.name, "testIndex");
    });

    test("Index.createIndex", () {
      final index =
          Index.createIndex<String>("testIndex", MockRegion<String>(), 10);
      expect(index, isA<Index<String>>());
      expect(index.name, "testIndex");
      expect(index.capacity, 10);
    });
  });
}
