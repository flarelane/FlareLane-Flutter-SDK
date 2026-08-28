import 'package:flarelane_flutter/src/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what `debugPrint` would have written so the level gate can be asserted without
/// reading the console.
List<String> _capture(void Function() body) {
  final printed = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) printed.add(message);
  };
  try {
    body();
  } finally {
    debugPrint = original;
  }
  return printed;
}

void main() {
  tearDown(() => Logger.level = LogLevel.verbose);

  test('defaults to verbose so behavior is unchanged until the app opts out', () {
    expect(Logger.level, LogLevel.verbose);
  });

  test('level values are the platform-independent wire format', () {
    expect(LogLevel.none.value, 0);
    expect(LogLevel.error.value, 1);
    expect(LogLevel.verbose.value, 5);
  });

  test('none silences every level', () {
    Logger.level = LogLevel.none;

    final printed = _capture(() {
      Logger.verbose('flow');
      Logger.error('failure');
    });

    expect(printed, isEmpty);
  });

  test('error passes failures only', () {
    Logger.level = LogLevel.error;

    final printed = _capture(() {
      Logger.verbose('flow');
      Logger.error('failure');
    });

    expect(printed, ['[FlareLane][ERROR] failure']);
  });

  test('verbose passes both, tagged with the shared format', () {
    Logger.level = LogLevel.verbose;

    final printed = _capture(() {
      Logger.verbose('flow');
      Logger.error('failure');
    });

    expect(printed, [
      '[FlareLane][VERBOSE] flow',
      '[FlareLane][ERROR] failure',
    ]);
  });
}
