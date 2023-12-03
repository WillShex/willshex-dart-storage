//
//  class.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

typedef T CreateFunction<T>();

///
/// @author William Shakour (billy1380)
///
class Class<T> {
  final String _name;
  final CreateFunction<T> _createFunction;

  const Class(this._name, this._createFunction);

  String get simpleName {
    return _name.split(".").last;
  }

  String get name {
    return _name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  bool operator ==(dynamic other) {
    return other != null && other is Class && other.name == this.name;
  }

  T instance() => _createFunction();
}
