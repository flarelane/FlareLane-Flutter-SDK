import 'dart:async';
import 'dart:io';

import 'package:flarelane_flutter/notification.dart';
import 'package:flutter/services.dart';

typedef NotificationConvertedHandler = void Function(
    FlareLaneNotification notification);
typedef GetTagsHandler = void Function(Map<String, dynamic> tags);
typedef SubscribeHandler = void Function(bool isSubscribed);

enum LogLevel { none, error, verbose }

class FlareLane {
  static FlareLane shared = FlareLane();

  final MethodChannel _channel =
      const MethodChannel('com.flarelane.flutter/methods');

  NotificationConvertedHandler? _notificationConvertedHandler;

  FlareLane() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  // ----- PUBLIC METHODS -----

  Future<void> initialize(String projectId,
      {bool? requestPermissionOnLaunch = true}) async {
    final bool result = await _channel.invokeMethod('initialize', {
      "projectId": projectId,
      "requestPermissionOnLaunch": requestPermissionOnLaunch
    });
    result
        ? print('[FlareLane] initialize completed.')
        : print('[FlareLane] initialize failed.');
  }

  Future<void> setLogLevel(LogLevel logLevel) async {
    await _channel.invokeMethod('setLogLevel', _convertLoglevel(logLevel));
  }

  Future<void> setUserId(String? userId) async {
    await _channel.invokeMethod('setUserId', userId);
  }

  Future<void> getTags(GetTagsHandler callback) async {
    Map<dynamic, dynamic> tags = await _channel.invokeMethod('getTags');
    callback(tags.cast<String, dynamic>());
  }

  Future<void> setTags(Map<String, Object> tags) async {
    await _channel.invokeMethod('setTags', tags);
  }

  Future<void> deleteTags(List<String> tags) async {
    await _channel.invokeMethod('deleteTags', tags);
  }

  Future<void> setIsSubscribed(bool isSubscribed,
      [SubscribeHandler? callback]) async {
    final bool _isSubscribed =
        await _channel.invokeMethod('setIsSubscribed', isSubscribed);

    if (callback != null) {
      callback(_isSubscribed);
    }
  }

  Future<bool> isSubscribed() async {
    final bool _isSubscribed = await _channel.invokeMethod('isSubscribed');
    return _isSubscribed;
  }

  Future<void> subscribe(
      [bool? fallbackToSettings = true, SubscribeHandler? callback]) async {
    final bool _isSubscribed =
        await _channel.invokeMethod('subscribe', fallbackToSettings);

    if (callback != null) {
      callback(_isSubscribed);
    }
  }

  Future<void> unsubscribe([SubscribeHandler? callback]) async {
    final bool _isSubscribed = await _channel.invokeMethod('unsubscribe');

    if (callback != null) {
      callback(_isSubscribed);
    }
  }

  Future<void> setAccentColor(String accentColor) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('setAccentColor', accentColor);
    }
  }

  void setNotificationConvertedHandler(NotificationConvertedHandler handler) {
    _notificationConvertedHandler = handler;
    _channel.invokeMethod("setNotificationConvertedHandler");
  }

  Future<String?> getDeviceId() async {
    final String? deviceId = await _channel.invokeMethod('getDeviceId');
    return deviceId;
  }

  Future<void> trackEvent(String type, [Map<String, Object>? data]) async {
    await _channel.invokeMethod('trackEvent', {"type": type, "data": data});
  }

  Future _handleMethod(MethodCall call) async {
    if (call.method == 'setNotificationConvertedHandlerInvokeCallback' &&
        _notificationConvertedHandler != null) {
      FlareLaneNotification notification =
          FlareLaneNotification(call.arguments.cast<String, dynamic>());
      _notificationConvertedHandler!(notification);
    }
  }

  int _convertLoglevel(LogLevel logLevel) {
    const iOSLogLevel = {
      LogLevel.none: 0,
      LogLevel.error: 1,
      LogLevel.verbose: 5
    };
    const androidLogLevel = {
      LogLevel.none: 10,
      LogLevel.error: 6,
      LogLevel.verbose: 2
    };

    if (Platform.isIOS) {
      return iOSLogLevel[logLevel] ?? iOSLogLevel[LogLevel.verbose]!;
    } else if (Platform.isAndroid) {
      return androidLogLevel[logLevel] ?? androidLogLevel[LogLevel.verbose]!;
    } else {
      throw "Unknown Platform";
    }
  }
}
