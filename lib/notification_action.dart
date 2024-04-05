import 'dart:convert';

class FlareLaneNotificationAction {
  late String type;
  String? url;
  Map? data;

  FlareLaneNotificationAction(Map<String, dynamic> json) {
    if (json.containsKey('type')) type = json['type'] as String;
    if (json.containsKey('url')) url = json['url'] as String?;
    if (json.containsKey('data')) {
      if (json['data'] is Map) {
        data = json['data'];
      } else if (json['data'] is String) {
        data = jsonDecode(json['data']);
      }
    }
  }

  @override
  String toString() {
    return 'FlareLaneNotificationAction{type: $type, url: $url, data: $data}';
  }
}
