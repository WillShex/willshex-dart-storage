import 'package:willshex/src/abstract_tree.dart';

class MockRegion<T> implements Region<T> {
  @override
  bool contains(T value) => true;

  @override
  bool intersects(Region<T> region) => true;

  @override
  Region<T> split(int value) => this;
}
