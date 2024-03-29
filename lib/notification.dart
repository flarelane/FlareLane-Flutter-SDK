import 'dart:convert';

class FlareLaneNotification {
  late String id;
  String? title;
  late String body;
  String? url;
  String? imageUrl;
  Map? data;

  FlareLaneNotification(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'] as String;
    if (json.containsKey('title')) title = json['title'] as String?;
    if (json.containsKey('body')) body = json['body'] as String;
    if (json.containsKey('url')) url = json['url'] as String?;
    if (json.containsKey('imageUrl')) imageUrl = json['imageUrl'] as String?;
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
    return 'FlareLaneNotification{id: $id, title: $title, body: $body, url: $url, imageUrl: $imageUrl, data: $data}';
  }
}
