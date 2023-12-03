//
//  deleteids.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:async';

///
/// @author William Shakour (billy1380)
///
abstract class DeleteIds {
  Future<void> id(int id);

  Future<void> ids(Iterable<int> ids);
}
