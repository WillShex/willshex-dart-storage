//
//  texturepack.dart
//  layout_editory
//
//  Created by William Shakour on March 31, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'package:willshex_dart_storage/storage.dart';

import 'texturepackregionimage.dart';

const Class<TexturePack> TEXTURE_PACK =
    const Class("TexturePack", TexturePack.new);

class TexturePack extends DataType {
  List<TexturePackRegionImage>? images;
  String? name;
  String? path;

  TexturePack({
    this.images,
    this.name,
    this.path,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: TEXTURE_PACK,
        );

  TexturePack.json(Map<String, dynamic> json) : super.json(json);
  TexturePack.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["images"] != null) {
      List<TexturePackRegionImage> images = <TexturePackRegionImage>[];
      TexturePackRegionImage item;
      for (Map<String, dynamic> jsonItem in json["images"]) {
        item = new TexturePackRegionImage()..fromJson(jsonItem);
        images.add(item);
      }
    }

    if (json["name"] != null) {
      name = json["name"];
    }

    if (json["path"] != null) {
      path = json["path"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (images != null) {
      List<Map<String, dynamic>> jsonArray = <Map<String, dynamic>>[];
      for (TexturePackRegionImage item in images!) {
        jsonArray.add(item.toJson());
      }
      json["images"] = jsonArray;
    }

    if (name != null) {
      json["name"] = name;
    }

    if (path != null) {
      json["path"] = path;
    }

    return json;
  }
}
