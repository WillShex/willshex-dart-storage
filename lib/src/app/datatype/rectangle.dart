//
//  rectangle.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';

const Class<Rectangle> RECTANGLE = const Class("Rectangle", Rectangle.new);

class Rectangle extends DataType {
  int? width;
  int? height;

  Rectangle({
    this.width,
    this.height,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: RECTANGLE,
        );

  Rectangle.json(Map<String, dynamic> json) : super.json(json);
  Rectangle.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

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

    if (width != null) {
      json["width"] = width;
    }

    if (height != null) {
      json["height"] = height;
    }

    return json;
  }
}
