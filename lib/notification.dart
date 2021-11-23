class FlareLaneNotification {
  late String id;
  String? title;
  late String body;
  String? url;

  FlareLaneNotification(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'] as String;
    if (json.containsKey('title')) title = json['title'] as String?;
    if (json.containsKey('body')) body = json['body'] as String;
    if (json.containsKey('url')) url = json['url'] as String?;
  }

  @override
  String toString() {
    return 'FlareLaneNotification{id: $id, title: $title, body: $body, url: $url}';
  }
}
