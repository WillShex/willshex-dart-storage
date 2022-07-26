//
//  scene.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex/willshex.dart';

import 'image.dart';
import 'label.dart';
import 'layout.dart';
import 'rectangle.dart';
import 'texturepack.dart';

const Class<Scene> SCENE = const Class("Scene", Scene.new);

class Scene extends DataType {
  List<Layout>? layouts;
  List<Image>? images;
  List<Label>? labels;
  List<TexturePack>? texturePacks;
  List<Rectangle>? rectangles;
  String? name;
  String? fileName;

  Scene({
    this.layouts,
    this.images,
    this.labels,
    this.texturePacks,
    this.rectangles,
    this.name,
    this.fileName,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: SCENE,
        );

  Scene.json(Map<String, dynamic> json) : super.json(json);
  Scene.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["layouts"] != null) {
      List<Layout> layouts = <Layout>[];
      Layout item;
      for (Map<String, dynamic> jsonItem in json["layouts"]) {
        item = new Layout()..fromJson(jsonItem);
        layouts.add(item);
      }
    }

    if (json["images"] != null) {
      List<Image> images = <Image>[];
      Image item;
      for (Map<String, dynamic> jsonItem in json["images"]) {
        item = new Image()..fromJson(jsonItem);
        images.add(item);
      }
    }

    if (json["labels"] != null) {
      List<Label> labels = <Label>[];
      Label item;
      for (Map<String, dynamic> jsonItem in json["labels"]) {
        item = new Label()..fromJson(jsonItem);
        labels.add(item);
      }
    }

    if (json["texturePacks"] != null) {
      List<TexturePack> texturePacks = <TexturePack>[];
      TexturePack item;
      for (Map<String, dynamic> jsonItem in json["texturePacks"]) {
        item = new TexturePack()..fromJson(jsonItem);
        texturePacks.add(item);
      }
    }

    if (json["rectangles"] != null) {
      List<Rectangle> rectangles = <Rectangle>[];
      Rectangle item;
      for (Map<String, dynamic> jsonItem in json["rectangles"]) {
        item = new Rectangle()..fromJson(jsonItem);
        rectangles.add(item);
      }
    }

    if (json["name"] != null) {
      name = json["name"];
    }

    if (json["fileName"] != null) {
      fileName = json["fileName"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (layouts != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (Layout item in layouts!) {
        jsonArray.add(item.toJson());
      }
      json["layouts"] = jsonArray;
    }

    if (images != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (Image item in images!) {
        jsonArray.add(item.toJson());
      }
      json["images"] = jsonArray;
    }

    if (labels != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (Label item in labels!) {
        jsonArray.add(item.toJson());
      }
      json["labels"] = jsonArray;
    }

    if (texturePacks != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (TexturePack item in texturePacks!) {
        jsonArray.add(item.toJson());
      }
      json["texturePacks"] = jsonArray;
    }

    if (rectangles != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (Rectangle item in rectangles!) {
        jsonArray.add(item.toJson());
      }
      json["rectangles"] = jsonArray;
    }

    if (name != null) {
      json["name"] = name;
    }

    if (fileName != null) {
      json["fileName"] = fileName;
    }

    return json;
  }
}
