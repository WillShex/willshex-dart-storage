import "dart:async";
import "dart:math";

import "src/data_type/image.dart";
import "src/data_type/scene.dart";
import "src/data_types.dart";

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
  Image? idLoaded = await DataTypes.store.load.image.id(image.id!);
  print("Loaded image with id ${image.id.toString()} ${idLoaded.toString()}");

  printTestTitle(
      "1b) load by id using filter id - this is comparatively inefficient");
  Image? filterIdLoaded =
      await DataTypes.store.load.image.filterId("=", image.id).first;
  print(
      "Loaded image with filter id ${image.id.toString()} ${filterIdLoaded.toString()}");

  printTestTitle("2a) load more than 1 id");
  Map<int, Image> idsLoaded = await DataTypes.store.load.image.ids(images.keys);
  print(
      "Loaded image with ids ${images.keys.toString()} ${idsLoaded.toString()}");

  printTestTitle("2b) load more than 1 id using filter id in");
  List<Image> filteridsLoaded =
      await DataTypes.store.load.image.filterId("in", images.keys).list;
  print(
      "Loaded image with filter ids ${images.keys.toString()} ${filteridsLoaded.toString()}");

  printTestTitle("3a) run a query based on a property");
  int width;
  List<Image> widthImages = await DataTypes.store.load.image
      .filter("width >=", width = images.values.first.width!)
      .list;
  print("Loaded images with width >= $width ${widthImages.toString()}");

  printTestTitle("3b) run a query based on a property and an id");
  List<Image> widthAndIdImages = await DataTypes.store.load.image
      .filterId(">", images.values.first.id)
      .filter("width >=", width = images.values.first.width!)
      .list;
  print(
      "Loaded image with width >= $width and id > ${images.values.first.id} ${widthAndIdImages.toString()}");

  printTestTitle("4) run a query that uses an offset");
  List<Image> offsetImages = await DataTypes.store.load.image
      .offset(2)
      .filterId(">", images.values.first.id)
      .list;
  print(
      "Loaded images with id > ${images.values.first.id} offset by 2 ${offsetImages.toString()}");

  printTestTitle("5) run a query that uses a limit");
  List<Image> limitImages = await DataTypes.store.load.image
      .filterId(">", images.values.first.id)
      .offset(3)
      .limit(2)
      .list;
  print(
      "Loaded images with id > ${images.values.first.id} offset by 3 and limit 2 ${limitImages.toString()}");

  printTestTitle("6) change a property and save");
  await DataTypes.store.save.entity(image..deleted = true);
  Image? deletedFlagImage = await DataTypes.store.load.image.id(image.id!);
  print("Image with updated property deleted ${deletedFlagImage.toString()}");

  printTestTitle("7) count query");
  int count = await DataTypes.store.load.image.count;
  print("Count of images: $count");

  printTestTitle("8) order query (ascending width)");
  List<Image> orderedImages =
      await DataTypes.store.load.image.order("width").list;
  print(
      "Images ordered by width: ${orderedImages.map((e) => e.width).toList()}");

  printTestTitle("9) order query (descending width)");
  List<Image> descOrderedImages =
      await DataTypes.store.load.image.order("-width").list;
  print(
      "Images ordered by width desc: ${descOrderedImages.map((e) => e.width).toList()}");

  printTestTitle("10) string filter (name > 'm')");
  // Assuming randomFileName generates names starting with various letters
  List<Image> stringFiltered =
      await DataTypes.store.load.image.filter("name >", "m").list;
  print("Images with name > 'm': ${stringFiltered.length}");

  printTestTitle("11) distinct query");
  Image img1 = createImage();
  Image img2 = createImage();
  // Sync properties to make them distinct-equivalent (except id, which is removed by distinct check)
  img2.name = img1.name;
  img2.path = img1.path;
  img2.width = img1.width;
  img2.height = img1.height;
  img2.created = img1.created;
  img2.deleted = img1.deleted;

  await DataTypes.store.save.entity(img1);
  await DataTypes.store.save.entity(img2);

  int totalCount = await DataTypes.store.load.image.count;
  List<Image> distinctImages =
      await DataTypes.store.load.image.distinct(true).list;
  print("Total: $totalCount, Distinct: ${distinctImages.length}");
  // Note: Distinct logic depends on how strictly all fields match.

  printTestTitle("12) Complex Object (Scene with embedded Images)");
  Scene scene = createScene();
  scene.images = [createImage(), createImage()];
  scene.id = await DataTypes.store.save.entity(scene);
  print(
      "Saved scene with id ${scene.id} and ${scene.images!.length} embedded images.");

  Scene? loadedScene = await DataTypes.store.load.scene.id(scene.id!);
  print("Loaded scene has ${loadedScene?.images?.length} images.");
  if (loadedScene?.images?.isNotEmpty ?? false) {
    print("First image name: ${loadedScene?.images?.first.name}");
  }

  printTestTitle("13) delete by id");
  Image toDelete = await insertImage();
  print("Created image to delete by id: ${toDelete.id}");
  await DataTypes.store.delete.image.id(toDelete.id!);
  Image? deletedCheck = await DataTypes.store.load.image.id(toDelete.id!);
  print("Image after delete by id (should be null): $deletedCheck");

  printTestTitle("14) IN operator filter");
  if (images.isNotEmpty) {
    List<String> namesToFind =
        images.values.take(2).map((e) => e.name!).toList();
    List<Image> inFiltered =
        await DataTypes.store.load.image.filter("name in", namesToFind).list;
    print("Images with name in $namesToFind: ${inFiltered.length}");
  }

  printTestTitle("15) Not Equals filter (width != 10)");
  List<Image> notEqualsFiltered =
      await DataTypes.store.load.image.filter("width !=", 10).list;
  print("Images with width != 10: ${notEqualsFiltered.length}");

  printTestTitle("16) Group By (width)");
  List<Image> grouped = await DataTypes.store.load.image.group("width").list;
  print("Grouped by width: ${grouped.length} groups");

  printTestTitle("17) Reverse");
  List<Image> reversed =
      await DataTypes.store.load.image.order("width").reverse().list;
  print("Reversed (width desc): ${reversed.map((e) => e.width).toList()}");

  printTestTitle("delete single entity");
  DataTypes.store.delete.entity(image);
  print("done");

  printTestTitle("delete multiple entity");
  DataTypes.store.delete.entities(images.values);

  // Clean up new tests
  DataTypes.store.delete.entity(img1);
  DataTypes.store.delete.entity(img2);
  DataTypes.store.delete.entity(scene);

  printTestTitle("done");

  return null;
}

void printTestTitle(String s) {
  print("---------------- $s ------------------");
}

Future<Image> insertImage() async {
  Image image = createImage();
  image.id = await DataTypes.store.save.entity(image);
  return image;
}

Future<Map<int, Image>> insertImages(int count) async {
  List<Image> images = <Image>[];
  for (int i = 0; i < count; i++) {
    images.add(createImage());
  }
  return await DataTypes.store.save.entities(images);
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
      created: DateTime.now(),
      deleted: false,
      height: random(10, 20),
      width: random(10, 20),
      name: randomFileName("png"),
      path: "images/");
}

Scene createScene() {
  return new Scene(
      created: DateTime.now(),
      deleted: false,
      name: "Test Scene ${randomLettersAndNumbers(5)}",
      fileName: "scene.json");
}
