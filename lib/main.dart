import 'dart:async';
import 'src/app/datatypes.dart';
import 'src/app/datatype/image.dart';
import 'dart:math';

Random generator = new Random();
const String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const String lower = "abcdefghijklmnopqrstuvwxyz";
const String numbers = "0123456789";

const String letters = "$upper$lower";
const String lettersAndNumbers = "$letters$numbers";

Future<Null> main(List<String> args) async {
  printTestTitle("insert single entity");
  Image image = await insertImage();
  print("Saved and image ${image.toString()}");

  printTestTitle("insert multiple entity");
  Map<int, Image> images = await insertImages(30);
  print("Saved multiple images ${<Image>[]
        ..addAll(images.values)
        ..toString()}");

  printTestTitle("1a) load by id");
  Image idLoaded = await DataTypes.store.load().type(IMAGE).id(image.id).now();
  print("Loaded image with id ${image.id.toString()} ${idLoaded.toString()}");

  printTestTitle(
      "1b) load by id using filter id - this is comparatively inefficient");
  Image filterIdLoaded = await DataTypes.store
      .load()
      .type(IMAGE)
      .filterId("=", image.id)
      .first()
      .now();
  print("Loaded image with filter id ${image.id.toString()} ${filterIdLoaded
          .toString()}");

  printTestTitle("2a) load more than 1 id");
  Map<int, Image> idsLoaded =
      await DataTypes.store.load().type(IMAGE).ids(images.keys).now();
  print("Loaded image with ids ${images.keys.toString()} ${idsLoaded
          .toString()}");

  printTestTitle("2b) load more than 1 id using filter id in");
  List<Image> filteridsLoaded = await DataTypes.store
      .load()
      .type(IMAGE)
      .filterId("in", images.keys)
      .list();
  print(
      "Loaded image with filter ids ${images.keys.toString()} ${filteridsLoaded
          .toString()}");

  printTestTitle("3a) run a query based on a property");
  int width;
  List<Image> widthImages = await DataTypes.store
      .load()
      .type(IMAGE)
      .filter("width >=", width = images.values.first.width)
      .list();
  print("Loaded images with width >= $width ${widthImages.toString()}");

  printTestTitle("3b) run a query based on a property and an id");
  List<Image> widthAndIdImages = await DataTypes.store
      .load()
      .type(IMAGE)
      .filterId(">", images.values.first.id)
      .filter("width >=", width = images.values.first.width)
      .list();
  print("Loaded image with width >= $width and id > ${images.values.first
          .id} ${widthAndIdImages.toString()}");

  printTestTitle("4) run a query that uses an offset");
  List<Image> offsetImages = await DataTypes.store
      .load()
      .type(IMAGE)
      .offset(2)
      .filterId(">", images.values.first.id)
      .list();
  print("Loaded images with id > ${images.values.first
          .id} offset by 2 ${offsetImages.toString()}");

  printTestTitle("5) run a query that uses a limit");
  List<Image> limitImages = await DataTypes.store
      .load()
      .type(IMAGE)
      .filterId(">", images.values.first.id)
      .offset(3)
      .limit(2)
      .list();
  print("Loaded images with id > ${images.values.first
          .id} offset by 3 and limit 2 ${limitImages.toString()}");

  printTestTitle("6) change a property and save");
  await DataTypes.store.save().entity(image..deleted = true).now();
  Image deletedFlagImage =
      await DataTypes.store.load().type(IMAGE).id(image.id).now();
  print("Image with updated property deleted ${deletedFlagImage.toString()}");

  printTestTitle("delete single entity");
  DataTypes.store.delete().entity(image).now();
  print("done");

  printTestTitle("delete multiple entity");
  DataTypes.store.delete().entities(images.values).now();
  printTestTitle("done");

  return null;
}

void printTestTitle(String s) {
  print("---------------- $s ------------------");
}

Future<Image> insertImage() async {
  Image image = createImage();
  image.id = await DataTypes.store.save().entity(image).now();
  return image;
}

Future<Map<int, Image>> insertImages(int count) async {
  List<Image> images = <Image>[];
  for (int i = 0; i < count; i++) {
    images.add(createImage());
  }
  return await DataTypes.store.save().entities(images).now();
}

int random(int min, int max) {
  double v = generator.nextDouble();
  return (min + ((max - min) * v)).toInt();
}

String randomFileName(String extension) {
  return "${randomLettersAndNumbers(7)}.$extension";
}

String randomLettersAndNumbers(int length) {
  String string = "";
  for (int i = 0; i < length; i++) {
    string += lettersAndNumbers[random(0, lettersAndNumbers.length)];
  }

  return string;
}

Image createImage() {
  return new Image(
      created: new DateTime.now(),
      deleted: false,
      height: random(10, 20),
      width: random(10, 20),
      name: randomFileName("png"),
      path: "images/");
}
