import 'package:flarelane_flutter/notification.dart';
import 'package:flutter/services.dart';

class FlareLaneNotificationReceivedEvent {
  late final MethodChannel _channel;
  late final FlareLaneNotification notification;

  FlareLaneNotificationReceivedEvent(this._channel, this.notification);

  void display() {
    _channel.invokeMethod(
        'displayNotification', {"notificationId": notification.id});
  }
}
