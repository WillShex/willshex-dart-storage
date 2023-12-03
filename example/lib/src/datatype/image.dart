//
//  image.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_dart_storage/storage.dart';

const Class<Image> IMAGE = const Class("Image", Image.new);

class Image extends DataType {
  String? name;
  String? path;
  int? width;
  int? height;

  Image({
    this.name,
    this.path,
    this.width,
    this.height,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: IMAGE,
        );

  Image.json(Map<String, dynamic> json) : super.json(json);
  Image.string(String string) : super.string(string);

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
