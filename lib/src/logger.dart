import 'package:flutter/foundation.dart';

/// Log verbosity, shared by all four FlareLane SDKs.
///
/// * [none] — print nothing at all.
/// * [error] — failures only: caught exceptions, HTTP errors, invalid parameters.
/// * [verbose] — errors plus the full operation flow. Default.
enum LogLevel { none, error, verbose }

/// Values handed to the native SDKs through the method channel. One value works on every
/// platform, so no per-platform conversion table is needed.
const Map<LogLevel, int> _levelValues = {
  LogLevel.none: 0,
  LogLevel.error: 1,
  LogLevel.verbose: 5,
};

extension LogLevelValue on LogLevel {
  int get value => _levelValues[this]!;
}

/// Dart-side counterpart of the native loggers.
///
/// The Dart layer needs its own gate: `setLogLevel` only used to travel to native, so Dart logs
/// kept printing at [LogLevel.none] — including in release builds, since `debugPrint` is not
/// stripped there.
///
/// Native logs the same calls, but the two surface in different places (a `flutter run` terminal
/// versus logcat / the Xcode console), so both are kept.
///
/// Output format is `[FlareLane][LEVEL] message`, identical across the four SDKs.
class Logger {
  /// Matches the native default so behavior is unchanged until the host app opts out.
  static LogLevel level = LogLevel.verbose;

  static void verbose(String message) {
    if (level.value >= LogLevel.verbose.value) {
      debugPrint('[FlareLane][VERBOSE] $message');
    }
  }

  static void error(String message) {
    if (level.value >= LogLevel.error.value) {
      debugPrint('[FlareLane][ERROR] $message');
    }
  }
}
