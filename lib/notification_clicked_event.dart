import 'package:flarelane_flutter/notification.dart';
import 'package:flarelane_flutter/notification_action.dart';

class FlareLaneNotificationClickedEvent {
  late final FlareLaneNotification notification;
  late final FlareLaneNotificationAction action;

  FlareLaneNotificationClickedEvent(this.notification, this.action);

  @override
  String toString() {
    return 'FlareLaneNotificationClickedEvent{notification: $notification, action: $action}';
  }
}
