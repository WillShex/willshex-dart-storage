# WillShex Storage

A robust, file-based storage library for Dart, designed for efficient data persistence, querying, and indexing.

## Features

- **File-Based Persistence**: Stores entities as JSON files for easy inspection and portability.
- **Advanced Querying**: Supports complex queries with filtering, sorting, grouping, and pagination.
- **Indexing**:
  - **Single-Field Indices**: Fast lookups on individual fields.
  - **Compound Indices**: Optimized performance for multi-field equality queries.
  - **Async Scanning**: Non-blocking index scanning for smooth performance.
- **Caching**: Built-in caching mechanism for faster data retrieval.
- **Code Generation**: Leverages `build_runner` to generate type-safe data models and storage classes.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  willshex_storage: ^0.1.0
```

## Usage

Define your data types and use the storage engine to save and retrieve them.

For a comprehensive guide and working code, please refer to the [example directory](example/).

### Basic Example

```dart
// Initialize storage
final storage = StorageProvider.provide(path);

// Save an entity
await storage.save.entity(myEntity);

// Query entities
final results = await storage.load.myEntity
    .filter("name", "Alice")
    .filter("age", 25) // Uses compound index if available
    .get();
```

## Additional Documentation

- **Compound Indices**: Automatically created and used when querying with multiple equality filters (e.g., `filter("a", 1).filter("b", 2)`).
