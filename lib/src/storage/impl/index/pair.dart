//
//  pair.dart
//  willshex
//
//  Created by William Shakour (billy1380) on 22 Apr 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import "package:meta/meta.dart";

@internal
class Pair<K, V> implements Comparable<Pair<K, V>> {
  final K key;
  final V value;

  Pair(this.key, this.value);

  @override
  String toString() {
    return "$key:$value";
  }

  static Pair<K, V> fromString<K, V>(String s) {
    int split = s.lastIndexOf(":");
    String keyString = s.substring(0, split);
    String valueString = s.substring(split + 1);

    dynamic key;
    if (K == int) {
      key = int.parse(keyString);
    } else if (K == double) {
      key = double.parse(keyString);
    } else if (K == num) {
      key = num.parse(keyString);
    } else if (K == bool) {
      key = keyString.toLowerCase() == "true";
    } else {
      key = keyString;
    }

    dynamic value;
    if (V == int) {
      value = int.parse(valueString);
    } else if (V == double) {
      value = double.parse(valueString);
    } else if (V == num) {
      value = num.parse(valueString);
    } else if (V == bool) {
      value = valueString.toLowerCase() == "true";
    } else {
      value = valueString;
    }

    return Pair<K, V>(key, value);
  }

  @override
  int compareTo(Pair<K, V> other) {
    int result = 0;
    if (key is Comparable) {
      result = (key as Comparable).compareTo(other.key);
    } else {
      result = key.toString().compareTo(other.key.toString());
    }

    if (result == 0) {
      if (value is Comparable) {
        result = (value as Comparable).compareTo(other.value);
      } else {
        result = value.toString().compareTo(other.value.toString());
      }
    }

    return result;
  }
}
