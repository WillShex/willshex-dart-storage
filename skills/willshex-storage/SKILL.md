---
name: willshex-storage
description: A robust, file-based storage library for Dart, designed for efficient data persistence, querying, and indexing.
---
# WillShex Storage Specialist

This skill provides comprehensive instructions for using the `willshex_storage` file-based storage library for Dart.

## Core Features
- **File-Based Persistence**: Entities are stored as JSON files under a configurable data directory.
- **Type-Safe Queries**: Leverages extensions on `Loader` and `Deleter` for compile-time safety.
- **Advanced Querying**: Supports filtering, sorting, pagination, distinct queries, reversing, and counts.
- **Automatic Caching**: Speeds up repeated lookups when enabled.
- **Automatic Compound Indexing**: Combines multi-field equality filters dynamically to speed up query execution.

## Getting Started

### 1. Dependency Configuration
Add the dependency to `pubspec.yaml`:
```yaml
dependencies:
  willshex_storage: ^0.1.1
```

Or for local path development:
```yaml
dependencies:
  willshex_storage:
    path: /path/to/willshex-dart-storage
```

And configure `build_runner` dev dependency:
```yaml
dev_dependencies:
  build_runner: ^2.4.10
```

### 2. Defining Data Models

Data models must inherit from `DataType`. Each model class needs:
1. Properties matching the database fields.
2. A constructor calling `super(sc: storageClass)`.
3. Deserialization constructor (`Image.json(Map<String, dynamic> json) : super.json(json)`).
4. Deserialization helper (`Image.string(String string) : super.string(string)`).
5. Implementation of `fromJson(Map<String, dynamic> json)` and `toJson()`.
6. `part "filename.sc.dart";` statement at the top of the file to wire up the generated Storage Class (SC).

#### Example: `lib/src/data_type/image.dart`
```dart
import "package:willshex_storage/storage.dart";

part "image.sc.dart";

class Image extends DataType {
  String? name;
  String? path;
  int? width;
  int? height;

  Image({
    this.name,
    this.path,
    this.width,
    this.height,
    super.id,
    super.created,
    super.deleted,
  }) : super(
          sc: imageStorageClass,
        );

  Image.json(Map<String, dynamic> json) : super.json(json) {
    sc = imageStorageClass;
  }

  Image.string(String string) : super.string(string) {
    sc = imageStorageClass;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = json["name"];
    path = json["path"];
    width = json["width"];
    height = json["height"];
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null) json["name"] = name;
    if (path != null) json["path"] = path;
    if (width != null) json["width"] = width;
    if (height != null) json["height"] = height;
    return json;
  }
}
```

### 3. Code Generation (build_runner)

The library uses `build_runner` to generate helper type accessors and configuration files (part files named `*.sc.dart`).

#### Enabling the Builder
In your project's `build.yaml`, you must enable the `willshex_storage|data_type_generator` builder:
```yaml
targets:
  $default:
    builders:
      willshex_storage|data_type_generator:
        enabled: true
```

#### Running the Generator
To generate the supporting storage files, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Generated Type Accessors & Helper Files
The generator analyzes your classes extending `DataType` and generates the corresponding `*.sc.dart` part files containing:
1. **The `Class<T>` registration constant**:
   ```dart
   const Class<Image> imageStorageClass = Class<Image>(
     "Image",
     Image.new,
     Image.string,
     Image.json,
   );
   ```
2. **Extensions for Type Accessors**:
   Generates extensions on `Loader`, `Deleter`, and `Compactor` to expose clean type getters:
   ```dart
   extension ImageLoaderEx on Loader {
     LoadType<Image> get image => type<Image>(imageStorageClass);
   }

   extension ImageDeleterEx on Deleter {
     DeleteType get image => type(imageStorageClass);
   }

   extension ImageCompactorEx on Compactor {
     Future<void> get image => type(imageStorageClass);
   }
   ```

#### Importing & Visibility of Type Accessors
> [!IMPORTANT]
> The generated type accessors (such as `.load.image` or `.delete.image`) are defined via Dart extensions on the `Loader`, `Deleter`, and `Compactor` classes.
> For these extensions to be in scope and usable on your storage instance, the model's main file (e.g., `import "src/data_type/image.dart";`) **must be explicitly imported** in the file where the storage queries are run.

### 4. Instantiating Storage
Instantiate storage using the `StorageProvider` and optionally configure caching:
```dart
import "package:willshex_storage/storage.dart";

abstract class DataTypes {
  static final Storage store = StorageProvider.provide(_path).cache(true);

  static Future<String> _path() {
    return Future.value("./data");
  }
}
```

---

## CRUD Operations

### Save Operations
- **Save a single entity** (returns the entity ID as `Future<int>`):
  ```dart
  int id = await DataTypes.store.save.entity(myImage);
  ```
- **Save multiple entities** (returns a `Map<int, Image>` mapping ID to entity):
  ```dart
  Map<int, Image> saved = await DataTypes.store.save.entities([img1, img2]);
  ```

### Load / Query Operations
- **Load by ID**:
  ```dart
  Image? image = await DataTypes.store.load.image.id(123);
  ```
- **Load multiple by IDs**:
  ```dart
  Map<int, Image> images = await DataTypes.store.load.image.ids([12, 34]);
  ```
- **Filter and load list**:
  ```dart
  List<Image> images = await DataTypes.store.load.image
      .filter("width >=", 10)
      .list;
  ```
- **Pagination**:
  ```dart
  List<Image> paginated = await DataTypes.store.load.image
      .offset(10)
      .limit(5)
      .list;
  ```
- **Sorting / Reverse**:
  ```dart
  List<Image> sorted = await DataTypes.store.load.image
      .order("width") // ascending
      .order("-height") // descending
      .reverse() // reverses order
      .list;
  ```
- **Grouping**:
  ```dart
  List<Image> grouped = await DataTypes.store.load.image
      .group("width")
      .list;
  ```
- **Distinct check**:
  ```dart
  List<Image> unique = await DataTypes.store.load.image
      .distinct(true)
      .list;
  ```
- **Record count**:
  ```dart
  int total = await DataTypes.store.load.image.count;
  ```

### Delete Operations
- **Delete single entity**:
  ```dart
  await DataTypes.store.delete.entity(myImage);
  ```
- **Delete multiple entities**:
  ```dart
  await DataTypes.store.delete.entities([img1, img2]);
  ```
- **Delete by ID**:
  ```dart
  await DataTypes.store.delete.image.id(123);
  ```
- **Delete multiple by IDs**:
  ```dart
  await DataTypes.store.delete.image.ids([12, 34]);
  ```
- **Delete all items of type**:
  ```dart
  await DataTypes.store.delete.image.all();
  ```
- **Drop storage** (Deletes all records and resets auto-increment ID generator back to 1):
  ```dart
  await DataTypes.store.delete.image.drop();
  ```

### Compact / Optimize Indexes
Compacts and updates the index for a storage class to optimize querying:
```dart
await DataTypes.store.compact.image;
```
