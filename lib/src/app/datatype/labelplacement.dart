//
//  labelplacement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'placement.dart';
import 'label.dart';

class LabelPlacement extends Placement {
  Label label;
  double size;
  bool mutable;
  String colour;

  LabelPlacement({
    this.label,
    this.size,
    this.mutable,
    this.colour,
    int x,
    int y,
    String name,
    int id,
    DateTime created,
    bool deleted,
  }) : super(
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

    if (json["label"] != null) {
      label = new Label()..fromJson(json["label"]);
    }

    if (json["size"] != null) {
      size = json["size"];
    }

    if (json["mutable"] != null) {
      mutable = json["mutable"];
    }

    if (json["colour"] != null) {
      colour = json["colour"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (label != null) {
      json["label"] = label.toJson();
    }

    if (size != null) {
      json["size"] = size;
    }

    if (mutable != null) {
      json["mutable"] = mutable;
    }

    if (colour != null) {
      json["colour"] = colour;
    }

    return json;
  }
}
