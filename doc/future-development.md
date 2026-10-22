# Possibilities for future development

Notes from a design discussion. Nothing here is implemented, and none of it is a commitment. The aim is to avoid re-deriving the analysis later.

Everything in the store is JSON, so the data is small by definition. That assumption drives most of the choices below.

## 1. Current concurrency behaviour

Safe:

- Concurrent futures in one isolate. Each `StorageImpl` keeps a per-file `ReadWriteLock` (`storage_impl.dart`). Reads share, writes are exclusive, and a queued write blocks the reads behind it.

Not safe:

- **Multiple isolates, or a second process, on the same data directory.** Locks, the cache (`c`) and the index-build map (`_indexBuilds`) are in-memory fields of each `StorageImpl`. Each isolate gets its own, so none of them see each other. There are no OS-level file locks.
- **The autoinc counter.** `_incrementCounter` reads `_.autoinc`, adds and writes. The read and the write are each locked, but the sequence is not. Two overlapping first saves of a type can be given the same id range, so one record overwrites the other. `_update` has the same race.
- **Index files.** Writes to them are unlocked, so concurrent saves can corrupt an index. Lazy index builds can interleave.
- **`drop`, `deleteAll`, `compact`.** They do not take the per-file locks around the directory delete, so they can race with in-flight saves.
- **Cache.** With `cache(true)`, one isolate serves stale entities after another isolate writes.

Cheap fix worth doing regardless of anything below: a per-type mutex around `_insert` and `_update` in `write_engine.dart`, with a test in `test/`.

## 2. Backend seam

`file_system_access.dart` already exposes a swappable seam (a global `fs` from `fs_shim`: `dart:io` on native, IndexedDB on web). Weaknesses:

- `fs` is a global, so two stores on different backends cannot coexist.
- The engines build paths by string concatenation and call `File`/`Directory` directly, which ties them to POSIX semantics.

Proposal: inject a small `StorageBackend` that exposes what the library needs, not what a filesystem offers.

```dart
abstract class StorageBackend {
  bool get supportsConditionalWrite;

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<bool> writeIf(String key, String value, {required String? expectedVersion});
  Future<void> delete(String key);
  Future<List<String>> list(String prefix);
}
```

`writeIf` (compare-and-swap) gives lock-free counters and index updates, and is what multi-writer safety rests on. A backend that cannot provide it says so, and the engine refuses multi-writer mode on it.

Backends: `fs_shim` (disk and web), in-memory (also moves the tests off real directories), and later Google Drive.

Step 1 is a behaviour-preserving refactor, so the existing tests are the safety net. Before starting, list every direct `File`/`Directory` call site in the engines to size it.

## 3. Making it multi-isolate safe

### Option A: one owner isolate, others proxy to it

Keeps the existing in-process locking, which is correct for one isolate.

- A storage server isolate owns the `StorageImpl` and takes commands over a `SendPort`.
- A proxy `Storage` in the other isolates serialises the query description (type name, filters, order, offset, limit, group, distinct) and sends it over. `Class<T>` holds constructor tear-offs that cannot cross a port, so send `type.name` and look it up in a registry on the server. Entities travel as `toStorable()` strings and are rebuilt with `Class.string`.
- Callers get copies, not shared instances.
- Works on every platform, including web (worker or `SharedWorker`).

### Option B: make the shared files safe (real multi-writer)

Each isolate keeps its own `StorageImpl` and the on-disk protocol becomes safe on its own. Much more work. `fs_shim` has no lock API (only internal `synchronized` locks in the IDB implementation).

Order of work:

1. Backend seam (section 2).
2. Atomic record writes: write `<id>.json.tmp`, rename over `<id>.json`, and make listings ignore `.tmp` files. Readers then never see a torn file, so reads need no cross-isolate lock.
3. `writeIf` on the backend. Disk: exclusive OS lock on a per-key lock file (`RandomAccessFile.lock`, which goes around `fs_shim`). Web: IndexedDB transactions (atomic across tabs and workers) or the Web Locks API. Memory: trivial.
4. Use compare-and-swap for counters (`_incrementCounter`, `_update`) with a retry loop, and for index updates and builds (build to a temp key, publish with `writeIf`). Keep the in-isolate `ReadWriteLock` as a fast path.
5. Define multi-file consistency. A save touches the record, the counter and several indexes with no transaction across them. Rule: the record file is the source of truth and indexes are hints, verified against the record on read. A stale index entry costs a wasted read, not a wrong result, and `compact` cleans them.
6. Cache: disable it in multi-writer mode, or add a per-type version key that is bumped on every write and checked before serving.
7. `drop`, `deleteAll`, `compact` take a type-level exclusive lock.
8. Tests: spawn N isolates doing saves, updates and deletes against one directory. Assert unique ids, no corrupt files, indexes consistent with records, and expected counts. Repeat runs, since races are probabilistic. `concurrent_write_test.dart` only covers futures in one isolate today.

Open question that decides web support: whether multiple processes (for example a desktop app plus a CLI on one store) are needed, or just multiple isolates in one app.

### Recommendation

Option A is a proxy layer over code that already works, and is far less work. Choose B only if separate processes must write to one store.

## 4. Why a plain filesystem interface does not suit Google Drive

| The library assumes | Drive |
|---|---|
| Cheap reads (a query is hundreds of sequential file reads) | Each read is a network round trip |
| Atomic rename (tmp-then-rename) | No atomic replace. Writes are by file id, and names are not unique |
| Paths identify files | Everything is addressed by id, so path lookup is a query |
| Read-after-write consistency | Mostly fine per file, but listings can lag |
| A lock | None |
| `list` is cheap and complete | Paginated and quota-limited |

Wrapping Drive in a fake `FileSystem` would work for tiny data and fall over under real queries, so use the backend interface instead.

## 5. Query engine direction (server, memory-resident)

Because the data is small, the engine can hold it in memory and use backends purely for persistence.

- At startup, load every record of each type into RAM. Queries (filter, order, group, offset, limit, count) run against RAM, so the existing cache effectively becomes the primary store.
- Indexes become in-memory structures rebuilt at load, so the `.index/` files go away. That removes index corruption and index-versus-record consistency problems.
- The backend interface shrinks to `readAll(type)`, `write(type, id, json)`, `delete(type, id)` and a counter.
- A server owns the store and clients reach it over HTTP. This is Option A with the network as the port. One isolate is enough for small data because the work is I/O-bound.
- Writes within the server only need a per-type mutex for counters and saves.

### Google Drive as a backend

- Load everything at startup and write through in the background.
- Drive addresses by id and names are not unique, so keep a name-to-id map in the backend.
- Do not create one Drive file per record. Pack them (one JSON file per type, or snapshot plus append-log segments) to stay inside rate limits.
- Writes take hundreds of milliseconds, so use a write-behind queue that coalesces updates to the same file and flushes on shutdown. A crash can lose the last few seconds. Make the flush interval and a "wait until durable" option explicit.
- Needs OAuth or a service account.

## 6. Multiple server instances

This is the hard combination: a memory-resident engine, several writers, and Drive. Two problems stack up:

1. **Write coordination.** Drive may not offer conditional writes.
2. **Cache coherence.** Each instance holds its own RAM copy, so a write on one leaves the others stale.

What was and was not verified: searches did not find Drive v3 documentation for `If-Match`/ETag on `files.update`, or for a compare-and-swap or lease-lock pattern. The pattern is documented for other Google APIs ([Cloud Storage preconditions](https://docs.cloud.google.com/storage/docs/request-preconditions), [Calendar version resources](https://developers.google.com/calendar/api/guides/version-resources)), but that does not show Drive supports it. Treat Drive as having no conditional writes until a test proves otherwise. Without them, two writers on one Drive file silently overwrite each other (last write wins).

Approach: separate coordination from persistence. The `supportsConditionalWrite` capability flag lets the engine refuse to start with more than one writer on a backend that cannot honour it.

Two workable shapes:

- **A. Single writer, many readers (preferred).** All writes go to one leader. Other instances forward writes to it and serve reads from RAM, refreshing when a per-type version stamp changes. The leader persists to Drive. A fixed writer deployment avoids leader election. Realistic for small data and a modest write rate.
- **B. A real coordination store.** Keep authoritative data and counters in something transactional (Firestore, Redis, SQL) and use Drive only for backup or export. Robust for true multi-writer, but then Drive is not really the backend.

### Spike to settle the Drive question

A throwaway script that runs N concurrent `files.update` calls with `If-Match` against one scratch Drive file and checks whether the stale ones get a 412. If they do, Drive can offer conditional writes and shape B-style multi-writer is possible on Drive. If not, use shape A. Needs a Drive credential and a scratch file.

## 7. Suggested order if this is picked up

1. Per-type mutex for counters and saves (fixes the single-isolate race).
2. `StorageBackend` interface with `fs_shim` and in-memory implementations, and move the tests onto in-memory.
3. Decide the process model (A, B, or the server direction) from the open questions above.
4. Memory-resident engine with in-memory indexes and a write-behind queue.
5. HTTP server layer: serialisable query description, JSON entities.
6. Drive backend, preceded by the spike.
