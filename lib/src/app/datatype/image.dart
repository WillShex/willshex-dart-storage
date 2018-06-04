//
//  image.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';

class Image extends DataType {
  String name;
  String path;
  int width;
  int height;

  Image({
    this.name,
    this.path,
    this.width,
    this.height,
    int id,
    DateTime created,
    bool deleted,
  })
      : super(
          id: id,
          created: created,
          deleted: deleted,
        );

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["name"] != null) {
      name = json["name"];
    }

    if (json["path"] != null) {
      path = json["path"];
    }

    if (json["width"] != null) {
      width = json["width"];
    }

    if (json["height"] != null) {
      height = json["height"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (name != null) {
      json["name"] = name;
    }

    if (path != null) {
      json["path"] = path;
    }

    if (width != null) {
      json["width"] = width;
    }

    if (height != null) {
      json["height"] = height;
    }

    return json;
  }
}
