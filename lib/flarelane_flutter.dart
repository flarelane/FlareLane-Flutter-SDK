import 'dart:async';

import 'package:flarelane_flutter/in_app_message.dart';
import 'package:flarelane_flutter/notification.dart';
import 'package:flarelane_flutter/notification_received_event.dart';
import 'package:flarelane_flutter/src/logger.dart';
import 'package:flutter/services.dart';

export 'package:flarelane_flutter/src/logger.dart' show LogLevel;

typedef NotificationClickedHandler = void Function(
    FlareLaneNotification notification);
typedef NotificationForegroundReceivedHandler = void Function(
    FlareLaneNotificationReceivedEvent event);
typedef InAppMessageActionHandler = void Function(
    InAppMessage iam, String actionId);
typedef GetTagsHandler = void Function(Map<String, dynamic> tags);
typedef IsSubscribedHandler = void Function(bool isSubscribed);

class FlareLane {
  static FlareLane shared = FlareLane();

  final MethodChannel _channel =
      const MethodChannel('com.flarelane.flutter/methods');

  NotificationClickedHandler? _notificationClickedHandler;
  NotificationForegroundReceivedHandler? _notificationForegroundReceivedHandler;
  InAppMessageActionHandler? _inAppMessageActionHandler;

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
        ? Logger.verbose('initialize completed.')
        : Logger.error('initialize failed.');
  }

  Future<void> setLogLevel(LogLevel logLevel) async {
    // Apply on the Dart side first: the channel hop is async, so anything logged in between
    // would otherwise still use the previous level.
    Logger.level = logLevel;
    await _channel.invokeMethod('setLogLevel', logLevel.value);
  }

  Future<void> setUserId(String? userId) async {
    Logger.verbose('setUserId: $userId');
    await _channel.invokeMethod('setUserId', userId);
  }

  Future<void> setTags(Map<String, Object?> tags) async {
    Logger.verbose('setTags: $tags');
    await _channel.invokeMethod('setTags', tags);
  }

  /// Set user attributes (name/email/phoneNumber/dob/timeZone/country/language, etc.).
  /// Sent only when userId is set, matching Web SDK behavior.
  Future<void> setUserAttributes(Map<String, Object?> attributes) async {
    Logger.verbose('setUserAttributes: $attributes');
    await _channel.invokeMethod('setUserAttributes', attributes);
  }

  Future<bool> isSubscribed() async {
    final bool _isSubscribed = await _channel.invokeMethod('isSubscribed');
    return _isSubscribed;
  }

  Future<void> subscribe(
      [bool? fallbackToSettings = true, IsSubscribedHandler? callback]) async {
    final bool _isSubscribed =
        await _channel.invokeMethod('subscribe', fallbackToSettings);

    if (callback != null) {
      callback(_isSubscribed);
    }
  }

  Future<void> unsubscribe([IsSubscribedHandler? callback]) async {
    final bool _isSubscribed = await _channel.invokeMethod('unsubscribe');

    if (callback != null) {
      callback(_isSubscribed);
    }
  }

  Future<void> displayInApp(String group,
      [Map<String, Object> data = const {}]) async {
    _channel.invokeMethod('displayInApp', {"group": group, "data": data});
  }

  void setNotificationClickedHandler(NotificationClickedHandler handler) {
    _notificationClickedHandler = handler;
    _channel.invokeMethod("setNotificationClickedHandler");
  }

  void setNotificationForegroundReceivedHandler(
      NotificationForegroundReceivedHandler handler) {
    _notificationForegroundReceivedHandler = handler;
    _channel.invokeMethod("setNotificationForegroundReceivedHandler");
  }

  void setInAppMessageActionHandler(InAppMessageActionHandler handler) {
    _inAppMessageActionHandler = handler;
    _channel.invokeMethod("setInAppMessageActionHandler");
  }

  Future<String?> getDeviceId() async {
    final String? deviceId = await _channel.invokeMethod('getDeviceId');
    return deviceId;
  }

  Future<void> trackEvent(String type, [Map<String, Object>? data]) async {
    Logger.verbose('trackEvent: $type, $data');
    await _channel.invokeMethod('trackEvent', {"type": type, "data": data});
  }

  Future _handleMethod(MethodCall call) async {
    if (call.method == 'setNotificationClickedHandlerInvokeCallback' &&
        _notificationClickedHandler != null) {
      FlareLaneNotification notification =
          FlareLaneNotification(call.arguments.cast<String, dynamic>());
      _notificationClickedHandler!(notification);
    } else if (call.method ==
            'setNotificationForegroundReceivedHandlerInvokeCallback' &&
        _notificationForegroundReceivedHandler != null) {
      FlareLaneNotification notification =
          FlareLaneNotification(call.arguments.cast<String, dynamic>());
      FlareLaneNotificationReceivedEvent event =
          FlareLaneNotificationReceivedEvent(_channel, notification);

      _notificationForegroundReceivedHandler!(event);
    } else if (call.method == 'setInAppMessageActionHandlerInvokeCallback' &&
        _inAppMessageActionHandler != null) {
      InAppMessage iam =
          InAppMessage(call.arguments['iam'].cast<String, dynamic>());
      String actionId = call.arguments['actionId'];
      _inAppMessageActionHandler!(iam, actionId);
    }
  }

}
