// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// DataTypeGenerator
// **************************************************************************

const Class<Image> imageStorageClass =
    Class("Image", Image.new, Image.string, Image.json);

extension ImageLoader on Loader {
  LoadType<Image> get image => type<Image>(imageStorageClass);
}

extension ImageDeleter on Deleter {
  DeleteType get image => type(imageStorageClass);
}

extension ImageCompactor on Compactor {
  Future<void> get image => type(imageStorageClass);
}
