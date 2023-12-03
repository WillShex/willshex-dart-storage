//
//  datatype.dart
//  blogwt
//
//  Created by William Shakour on March 21, 2018.
//  Copyright © 2018 WillShex Limited. All rights reserved.
//

import 'dart:convert';

import 'package:willshex/willshex.dart';

mixin Storable {
  Map<String, dynamic> toJsonStorable();
  String toStorable() => jsonEncode(toJsonStorable());
}

abstract class DataType extends Jsonable with Storable {
  late Class<dynamic> sc;

  int? id;
  DateTime? created;
  bool? deleted;

  DataType({
    required Class<dynamic> sc,
    this.id,
    this.created,
    this.deleted,
  }) {
    this.sc = sc;
  }

  DataType.json(Map<String, dynamic> json) : super.json(json);
  DataType.string(String string) : super.string(string);

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);

    if (json["id"] != null) {
      id = json["id"];
    }

    if (json["created"] != null) {
      created = json["created"] is int
          ? DateTime.fromMillisecondsSinceEpoch(json["created"])
          : DateTime.tryParse(json["created"]);
    }

    if (json["deleted"] != null) {
      deleted = json["deleted"];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();

    if (id != null) {
      json["id"] = id;
    }

    if (created != null) {
      json["created"] = created?.toIso8601String();
    }

    if (deleted != null) {
      json["deleted"] = deleted;
    }

    return json;
  }

  Map<String, dynamic> toJsonRef() {
    Map<String, dynamic> json = super.toJson();

    if (id != null) {
      json["id"] = id;
    }

    return json;
  }

  @override
  Map<String, dynamic> toJsonStorable() => toJson();
}
