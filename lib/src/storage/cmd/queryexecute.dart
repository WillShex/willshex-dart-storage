//
//  QueryExecute.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

typedef Future<List<T>> ListFunction<T>();
typedef Future<T> FirstFunction<T>();

///
/// @author William Shakour (billy1380)
///
class QueryExecute<T> {
  ListFunction<T> _listCall;
  FirstFunction<T> _firstCall;

  QueryExecute(this._firstCall, this._listCall);

  Future<List<T>> get list async {
    return _listCall();
  }

  Future<T?> get first {
    return _firstCall();
  }
}
