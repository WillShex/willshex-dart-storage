import "dart:async";

import "package:test/test.dart";
import "package:willshex_storage/src/storage/impl/read_write_lock.dart";

void main() {
  group("ReadWriteLock", () {
    late ReadWriteLock lock;
    late List<String> log;

    setUp(() {
      lock = ReadWriteLock();
      log = [];
    });

    Future<void> read(String name, Completer<void> release) =>
        lock.read(() async {
          log.add("$name start");
          await release.future;
          log.add("$name end");
        });

    Future<void> write(String name, Completer<void> release) =>
        lock.write(() async {
          log.add("$name start");
          await release.future;
          log.add("$name end");
        });

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 10));

    test("reads run together", () async {
      Completer<void> a = Completer<void>(), b = Completer<void>();

      Future<void> first = read("a", a);
      Future<void> second = read("b", b);
      await settle();

      expect(log, ["a start", "b start"]);

      a.complete();
      b.complete();
      await Future.wait([first, second]);
    });

    test("a write waits for the reads in progress", () async {
      Completer<void> r = Completer<void>(), w = Completer<void>();

      Future<void> reading = read("r", r);
      Future<void> writing = write("w", w);
      await settle();

      expect(log, ["r start"]);

      r.complete();
      await settle();

      expect(log, ["r start", "r end", "w start"]);

      w.complete();
      await Future.wait([reading, writing]);
    });

    test("reads wait while a write is running", () async {
      Completer<void> w = Completer<void>(), r = Completer<void>();

      Future<void> writing = write("w", w);
      Future<void> reading = read("r", r);
      await settle();

      expect(log, ["w start"]);

      w.complete();
      await settle();

      expect(log, ["w start", "w end", "r start"]);

      r.complete();
      await Future.wait([writing, reading]);
    });

    test("a read that arrives behind a waiting write waits for it", () async {
      Completer<void> a = Completer<void>(),
          w = Completer<void>(),
          b = Completer<void>();

      Future<void> first = read("a", a);
      Future<void> writing = write("w", w);
      Future<void> second = read("b", b);
      await settle();

      expect(log, ["a start"]);

      a.complete();
      await settle();

      expect(log, ["a start", "a end", "w start"]);

      w.complete();
      await settle();

      expect(log, ["a start", "a end", "w start", "w end", "b start"]);

      b.complete();
      await Future.wait([first, writing, second]);
    });

    test("reads that waited for a write start together", () async {
      Completer<void> w = Completer<void>(),
          a = Completer<void>(),
          b = Completer<void>();

      Future<void> writing = write("w", w);
      Future<void> first = read("a", a);
      Future<void> second = read("b", b);
      await settle();

      w.complete();
      await settle();

      expect(log, ["w start", "w end", "a start", "b start"]);

      a.complete();
      b.complete();
      await Future.wait([writing, first, second]);
    });

    test("a failing action gives the lock up", () async {
      await expectLater(
          lock.write(() async => throw StateError("failed")), throwsStateError);

      expect(await lock.read(() async => "read"), "read");
    });

    test("it is idle once everything has finished", () async {
      Completer<void> w = Completer<void>();

      expect(lock.isIdle, isTrue);

      Future<void> writing = write("w", w);
      expect(lock.isIdle, isFalse);

      w.complete();
      await writing;

      expect(lock.isIdle, isTrue);
    });
  });
}
