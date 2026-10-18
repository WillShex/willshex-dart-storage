import "dart:async";
import "dart:collection";

import "package:meta/meta.dart";

///
/// Any number of reads can run together, but a write runs on its own: it
/// waits for the reads in progress, and reads that arrive after it wait for it.
///
@internal
class ReadWriteLock {
  int _readers = 0;
  bool _writing = false;
  // whether the request is a write, and the completer for its turn
  final Queue<MapEntry<bool, Completer<void>>> _waiting =
      Queue<MapEntry<bool, Completer<void>>>();

  bool get isIdle => _readers == 0 && !_writing && _waiting.isEmpty;

  Future<T> read<T>(Future<T> Function() action) => _run(false, action);

  Future<T> write<T>(Future<T> Function() action) => _run(true, action);

  Future<T> _run<T>(bool exclusive, Future<T> Function() action) async {
    await _acquire(exclusive);

    try {
      return await action();
    } finally {
      _release(exclusive);
    }
  }

  Future<void> _acquire(bool exclusive) {
    if (_waiting.isEmpty && _canRun(exclusive)) {
      _take(exclusive);

      return Future<void>.value();
    }

    Completer<void> turn = Completer<void>();
    _waiting.add(MapEntry<bool, Completer<void>>(exclusive, turn));

    return turn.future;
  }

  bool _canRun(bool exclusive) =>
      exclusive ? _readers == 0 && !_writing : !_writing;

  void _take(bool exclusive) {
    if (exclusive) {
      _writing = true;
    } else {
      _readers++;
    }
  }

  void _release(bool exclusive) {
    if (exclusive) {
      _writing = false;
    } else {
      _readers--;
    }

    // the next in line go, and so do the reads queued behind a read
    while (_waiting.isNotEmpty && _canRun(_waiting.first.key)) {
      MapEntry<bool, Completer<void>> next = _waiting.removeFirst();

      _take(next.key);
      next.value.complete();
    }
  }
}
