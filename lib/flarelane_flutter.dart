import 'dart:async';

import 'package:flutter/services.dart';

import 'notification.dart';
import 'utils.dart';

typedef NotificationConvertedHandler = void Function(
    FlareLaneNotification notification);

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

  Future<void> initialize(String projectId) async {
    final bool result = await _channel.invokeMethod('initialize', projectId);
    result
        ? print('[FlareLane] initialize completed.')
        : print('[FlareLane] initialize failed.');
  }

  Future<void> setLogLevel(LogLevel logLevel) async {
    await _channel.invokeMethod('setLogLevel', convertLoglevel(logLevel));
  }

  Future<void> setUserId(String? userId) async {
    await _channel.invokeMethod('setUserId', userId);
  }

  Future<void> setTags(Map<String, Object> tags) async {
    await _channel.invokeMethod('setTags', tags);
  }

  Future<void> deleteTags(List<String> tags) async {
    await _channel.invokeMethod('deleteTags', tags);
  }

  Future<void> setIsSubscribed(bool isSubscribed) async {
    await _channel.invokeMethod('setIsSubscribed', isSubscribed);
  }

  void setNotificationConvertedHandler(NotificationConvertedHandler handler) {
    _notificationConvertedHandler = handler;
    _channel.invokeMethod("setNotificationConvertedHandler");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'setNotificationConvertedHandlerInvokeCallback' &&
        _notificationConvertedHandler != null) {
      FlareLaneNotification notification =
          FlareLaneNotification(call.arguments.cast<String, dynamic>());
      _notificationConvertedHandler!(notification);
    }
  }
}
