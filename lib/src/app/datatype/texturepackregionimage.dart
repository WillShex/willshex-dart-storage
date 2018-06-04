//
//  texturepackregionimage.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'image.dart';

class TexturePackRegionImage extends Image {
  int x;
  int y;
  int offsetX;
  int offsetY;
  int frameWidth;
  int frameHeight;

  TexturePackRegionImage({
    this.x,
    this.y,
    this.offsetX,
    this.offsetY,
    this.frameWidth,
    this.frameHeight,
    String name,
    String path,
    int width,
    int height,
    int id,
    DateTime created,
    bool deleted,
  })
      : super(
          name: name,
          path: path,
          width: width,
          height: height,
          id: id,
          created: created,
          deleted: deleted,
        );

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["x"] != null) {
      x = json["x"];
    }

    if (json["y"] != null) {
      y = json["y"];
    }

    if (json["offsetX"] != null) {
      offsetX = json["offsetX"];
    }

    if (json["offsetY"] != null) {
      offsetY = json["offsetY"];
    }

    if (json["frameWidth"] != null) {
      frameWidth = json["frameWidth"];
    }

    if (json["frameHeight"] != null) {
      frameHeight = json["frameHeight"];
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

    if (offsetX != null) {
      json["offsetX"] = offsetX;
    }

    if (offsetY != null) {
      json["offsetY"] = offsetY;
    }

    if (frameWidth != null) {
      json["frameWidth"] = frameWidth;
    }

    if (frameHeight != null) {
      json["frameHeight"] = frameHeight;
    }

    return json;
  }
}
