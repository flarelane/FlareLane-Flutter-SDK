import 'dart:io';

import 'flarelane_flutter.dart';

const iOSLogLevel = {0: 0, 1: 1, 2: 5};

const androidLogLevel = {0: 10, 1: 6, 2: 2};

int convertLoglevel(LogLevel logLevel) {
  if (Platform.isIOS) {
    return iOSLogLevel[logLevel.index] ?? 5;
  } else {
    return androidLogLevel[logLevel.index] ?? 2;
  }
}
