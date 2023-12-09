//
//  Query.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/src/storage/cmd/simplequery.dart';

///
/// @author William Shakour (billy1380)
///
abstract class Query<T> implements SimpleQuery<T> {
  Query<T> filter(String condition, dynamic value);

  Query<T> order(String condition);

  Query<T> group(String condition);

  @override
  Query<T> filterId(String condition, dynamic value);

  @override
  Query<T> limit(int value);

  @override
  Query<T> offset(int value);

  @override
  Query<T> reverse();
}
