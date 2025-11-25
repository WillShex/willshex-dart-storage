// GENERATED CODE - DO NOT MODIFY BY HAND

part of "image.dart";

// **************************************************************************
// DataTypeGenerator
// **************************************************************************

const Class<Image> imageStorageClass = Class<Image>(
  "Image",
  Image.new,
  Image.string,
  Image.json,
);

extension ImageLoaderEx on Loader {
  LoadType<Image> get image => type<Image>(imageStorageClass);
}

extension ImageDeleterEx on Deleter {
  DeleteType get image => type(imageStorageClass);
}

extension ImageCompactorEx on Compactor {
  Future<void> get image => type(imageStorageClass);
}
