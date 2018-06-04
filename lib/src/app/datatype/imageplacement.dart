//
//  imageplacement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'placement.dart';
import 'image.dart';

class ImagePlacement extends Placement {
  Image image;
  double scale;
  bool flipX;
  bool flipY;

  ImagePlacement({
    this.image,
    this.scale,
    this.flipX,
    this.flipY,
    int x,
    int y,
    String name,
    int id,
    DateTime created,
    bool deleted,
  })
      : super(
          x: x,
          y: y,
          name: name,
          id: id,
          created: created,
          deleted: deleted,
        );

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["image"] != null) {
      image = new Image()..fromJson(json["image"]);
    }

    if (json["scale"] != null) {
      scale = json["scale"];
    }

    if (json["flipX"] != null) {
      flipX = json["flipX"];
    }

    if (json["flipY"] != null) {
      flipY = json["flipY"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (image != null) {
      json["image"] = image.toJson();
    }

    if (scale != null) {
      json["scale"] = scale;
    }

    if (flipX != null) {
      json["flipX"] = flipX;
    }

    if (flipY != null) {
      json["flipY"] = flipY;
    }

    return json;
  }
}
