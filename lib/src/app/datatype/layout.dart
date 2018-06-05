//
//  layout.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';
import 'placement.dart';

class Layout extends DataType {
  List<Placement> items;
  String name;
  int width;
  int height;
  bool locked;

  Layout({
    this.items,
    this.name,
    this.width,
    this.height,
    this.locked,
    int id,
    DateTime created,
    bool deleted,
  }) : super(
          id: id,
          created: created,
          deleted: deleted,
        );

  Layout.json(Map<String, dynamic> json) : super.json(json);
  Layout.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["items"] != null) {
      List<Placement> items = <Placement>[];
      Placement item;
      for (Map<String, dynamic> jsonItem in json["items"]) {
        item = new Placement()..fromJson(jsonItem);
        items.add(item);
      }
    }

    if (json["name"] != null) {
      name = json["name"];
    }

    if (json["width"] != null) {
      width = json["width"];
    }

    if (json["height"] != null) {
      height = json["height"];
    }

    if (json["locked"] != null) {
      locked = json["locked"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (items != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (Placement item in items) {
        jsonArray.add(item.toJson());
      }
      json["items"] = jsonArray;
    }

    if (name != null) {
      json["name"] = name;
    }

    if (width != null) {
      json["width"] = width;
    }

    if (height != null) {
      json["height"] = height;
    }

    if (locked != null) {
      json["locked"] = locked;
    }

    return json;
  }
}
