//
//  imageplacement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/storage.dart';

import 'image.dart';
import 'placement.dart';

const Class<ImagePlacement> IMAGE_PLACEMENT = const Class(
  "ImagePlacement",
  ImagePlacement.new,
  ImagePlacement.string,
  ImagePlacement.json,
);

class ImagePlacement extends Placement {
  Image? image;
  double? scale;
  bool? flipX;
  bool? flipY;

  ImagePlacement({
    this.image,
    this.scale,
    this.flipX,
    this.flipY,
    super.x,
    super.y,
    super.name,
    super.id,
    super.created,
    super.deleted,
  }) {
    super.sc = IMAGE_PLACEMENT;
  }

  ImagePlacement.json(Map<String, dynamic> json) : super.json(json);
  ImagePlacement.string(String string) : super.string(string);

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
      json["image"] = image!.toJson();
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
