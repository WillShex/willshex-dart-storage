//
//  CompactorImpl.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:willshex_storage/src/storage/impl/storage_impl.dart';
import 'package:willshex_storage/storage.dart';

///
/// @author William Shakour (billy1380)
///
@internal
class CompactorImpl implements Compactor {
  StorageImpl<Storage> store;

  CompactorImpl(this.store);

  @override
  Future<void> type<E>(Class<E> type) async {}
}
