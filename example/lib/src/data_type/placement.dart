//
//  placement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/storage.dart';

part 'placement.sc.dart';

class Placement extends DataType {
  int? x;
  int? y;
  String? name;

  Placement({
    this.x,
    this.y,
    this.name,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: placementStorageClass,
        );

  Placement.json(Map<String, dynamic> json) : super.json(json);
  Placement.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["x"] != null) {
      x = json["x"];
    }

    if (json["y"] != null) {
      y = json["y"];
    }

    if (json["name"] != null) {
      name = json["name"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (x != null) {
      json["x"] = x;
    }

    if (y != null) {
      json["y"] = y;
    }

    if (name != null) {
      json["name"] = name;
    }

    return json;
  }
}
