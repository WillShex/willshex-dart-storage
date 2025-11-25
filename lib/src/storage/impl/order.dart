//
//  Order.dart
//  storage
//
//  Created by William Shakour (billy1380) on 28 Mar 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import "package:meta/meta.dart";
import "package:willshex/willshex.dart";

///
/// @author William Shakour (billy1380)
///
@internal
class Order {
  final String fieldName;
  final SortDirectionType direction;

  const Order(this.fieldName, this.direction);
}
