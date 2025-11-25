// GENERATED CODE - DO NOT MODIFY BY HAND

part of "placement.dart";

// **************************************************************************
// DataTypeGenerator
// **************************************************************************

const Class<Placement> placementStorageClass = Class<Placement>(
  "Placement",
  Placement.new,
  Placement.string,
  Placement.json,
);

extension PlacementLoaderEx on Loader {
  LoadType<Placement> get placement => type<Placement>(placementStorageClass);
}

extension PlacementDeleterEx on Deleter {
  DeleteType get placement => type(placementStorageClass);
}

extension PlacementCompactorEx on Compactor {
  Future<void> get placement => type(placementStorageClass);
}
