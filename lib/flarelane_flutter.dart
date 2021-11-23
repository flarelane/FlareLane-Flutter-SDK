
import 'dart:async';

import 'package:flutter/services.dart';

class FlareLaneFlutter {
  static const MethodChannel _channel = MethodChannel('flarelane_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
