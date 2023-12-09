//
//  labelplacement.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_storage/storage.dart';

import 'label.dart';
import 'placement.dart';

const Class<LabelPlacement> LABEL_PLACEMENT =
    const Class("LabelPlacement", LabelPlacement.new);

class LabelPlacement extends Placement {
  Label? label;
  double? size;
  bool? mutable;
  String? colour;

  LabelPlacement({
    this.label,
    this.size,
    this.mutable,
    this.colour,
    super.x,
    super.y,
    super.name,
    super.id,
    super.created,
    super.deleted,
  }) {
    super.sc = LABEL_PLACEMENT;
  }

  LabelPlacement.json(Map<String, dynamic> json) : super.json(json);
  LabelPlacement.string(String string) : super.string(string);

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
      json["label"] = label!.toJson();
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
