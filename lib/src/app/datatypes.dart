import 'dart:async';

import 'package:willshex/willshex.dart';

import 'datatype/image.dart';
import 'datatype/imageplacement.dart';
import 'datatype/label.dart';
import 'datatype/labelplacement.dart';
import 'datatype/layout.dart';
import 'datatype/placement.dart';
import 'datatype/rectangle.dart';
import 'datatype/rectangleplacement.dart';
import 'datatype/scene.dart';
import 'datatype/texturepack.dart';
import 'datatype/texturepackregionimage.dart';

const Class<Image> IMAGE = const Class(Image);
const Class<ImagePlacement> IMAGE_PLACEMENT = const Class(ImagePlacement);
const Class<Label> LABEL = const Class(Label);
const Class<LabelPlacement> LABEL_PLACEMENT = const Class(LabelPlacement);
const Class<Layout> LAYOUT = const Class(Layout);
const Class<Placement> PLACEMENT = const Class(Placement);
const Class<Rectangle> RECTANGLE = const Class(Rectangle);
const Class<RectanglePlacement> RECTANGLE_PLACEMENT =
    const Class(RectanglePlacement);
const Class<Scene> SCENE = const Class(Scene);
const Class<TexturePack> TEXTURE_PACK = const Class(TexturePack);
const Class<TexturePackRegionImage> TEXTURE_PACK_REGION_IMAGE =
    const Class(TexturePackRegionImage);

abstract class DataTypes {
  static final Storage store = StorageProvider.provide(_path).cache(true)
    ..register(IMAGE, () => new Image())
    ..register(IMAGE_PLACEMENT, () => new ImagePlacement())
    ..register(LABEL, () => new Label())
    ..register(LABEL_PLACEMENT, () => new LabelPlacement())
    ..register(LAYOUT, () => new Layout())
    ..register(PLACEMENT, () => new Placement())
    ..register(RECTANGLE, () => new Rectangle())
    ..register(RECTANGLE_PLACEMENT, () => new RectanglePlacement())
    ..register(SCENE, () => new Scene())
    ..register(TEXTURE_PACK, () => new TexturePack())
    ..register(TEXTURE_PACK_REGION_IMAGE, () => new TexturePackRegionImage());

  static Future<String> _path() {
    return new Future.value("./data");
  }
}
