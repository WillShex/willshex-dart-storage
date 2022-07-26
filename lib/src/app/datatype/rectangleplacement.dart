//
//  rectangleplacement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';

import 'placement.dart';
import 'rectangle.dart';

const Class<RectanglePlacement> RECTANGLE_PLACEMENT =
    const Class("RectanglePlacement", RectanglePlacement.new);

class RectanglePlacement extends Placement {
  Rectangle? rectangle;
  String? colour;
  int? cornerRadius;
  int? alpha;

  RectanglePlacement({
    this.rectangle,
    this.colour,
    this.cornerRadius,
    this.alpha,
    super.x,
    super.y,
    super.name,
    super.id,
    super.created,
    super.deleted,
  }) {
    super.sc = RECTANGLE_PLACEMENT;
  }

  RectanglePlacement.json(Map<String, dynamic> json) : super.json(json);
  RectanglePlacement.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["rectangle"] != null) {
      rectangle = new Rectangle()..fromJson(json["rectangle"]);
    }

    if (json["colour"] != null) {
      colour = json["colour"];
    }

    if (json["cornerRadius"] != null) {
      cornerRadius = json["cornerRadius"];
    }

    if (json["alpha"] != null) {
      alpha = json["alpha"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (rectangle != null) {
      json["rectangle"] = rectangle!.toJson();
    }

    if (colour != null) {
      json["colour"] = colour;
    }

    if (cornerRadius != null) {
      json["cornerRadius"] = cornerRadius;
    }

    if (alpha != null) {
      json["alpha"] = alpha;
    }

    return json;
  }
}
