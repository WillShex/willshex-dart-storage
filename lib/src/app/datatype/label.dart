//
//  label.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';

class Label extends DataType {
  double size;
  String text;
  String fontName;
  bool bold;
  bool italic;

  Label({
    this.size,
    this.text,
    this.fontName,
    this.bold,
    this.italic,
    int id,
    DateTime created,
    bool deleted,
  }) : super(
          id: id,
          created: created,
          deleted: deleted,
        );

  Label.json(Map<String, dynamic> json) : super.json(json);
  Label.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["size"] != null) {
      size = json["size"];
    }

    if (json["text"] != null) {
      text = json["text"];
    }

    if (json["fontName"] != null) {
      fontName = json["fontName"];
    }

    if (json["bold"] != null) {
      bold = json["bold"];
    }

    if (json["italic"] != null) {
      italic = json["italic"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (size != null) {
      json["size"] = size;
    }

    if (text != null) {
      json["text"] = text;
    }

    if (fontName != null) {
      json["fontName"] = fontName;
    }

    if (bold != null) {
      json["bold"] = bold;
    }

    if (italic != null) {
      json["italic"] = italic;
    }

    return json;
  }
}
