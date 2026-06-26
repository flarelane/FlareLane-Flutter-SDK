class FlareLaneNotificationButton {
  final String label;
  final String? link;

  FlareLaneNotificationButton({required this.label, this.link});

  /// Parse a button entry from the bridge payload, returning `null` when the entry is
  /// malformed (missing/non-string/empty `label`). A `factory` constructor can't return
  /// null, so this is a regular static method — callers filter the nulls out instead of
  /// catching a runtime cast error. Native already drops empty-label entries before
  /// sending; this is a defensive net for unexpected wire shapes.
  static FlareLaneNotificationButton? fromJson(Map json) {
    final label = json['label'];
    if (label is! String || label.isEmpty) return null;
    // Defensively check `link` shape too: a non-String value would crash the
    // `as String?` cast at runtime. Drop unexpected shapes silently — better
    // to lose the link than to take the host app down.
    final link = json['link'];
    return FlareLaneNotificationButton(
      label: label,
      link: link is String ? link : null,
    );
  }

  @override
  String toString() =>
      'FlareLaneNotificationButton{label: $label, link: $link}';
}

/// Pure data class — every field is populated from the native bridge payload (no derived
/// logic, no branching). Native (Android/iOS) is the single source of truth for "what was
/// clicked / where to go"; this layer just reflects what it was handed. Keep it that way
/// to avoid drift between platforms.
class FlareLaneNotification {
  late String id;
  String? title;
  late String body;
  String? url;
  String? imageUrl;
  Map? data;
  List<FlareLaneNotificationButton>? buttons;

  /// Index of the action button that was tapped, or `null` for a body click. Doubles as the
  /// "was it a button click?" check via `notification.clickedButtonIndex != null`.
  int? clickedButtonIndex;

  /// The button that was tapped, or `null` for a body click / out-of-range index.
  FlareLaneNotificationButton? clickedButton;

  /// URL associated with the click:
  ///   - Button click → the tapped button's link, or `null` when it has no link.
  ///   - Body click   → the notification body's [url], or `null` when none is set.
  /// A button click with no link returns `null`, **not** the body's [url].
  String? clickedUrl;

  FlareLaneNotification(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'] as String;
    if (json.containsKey('title')) title = json['title'] as String?;
    if (json.containsKey('body')) body = json['body'] as String;
    if (json.containsKey('url')) url = json['url'] as String?;
    if (json.containsKey('imageUrl')) imageUrl = json['imageUrl'] as String?;
    // Bridge always sends `data` as a parsed Map (iOS Dictionary / Android pre-parsed via
    // toHashMap). No JSON-string fallback needed in this layer.
    if (json['data'] is Map) {
      data = json['data'];
    }
    if (json['buttons'] is List) {
      // `fromJson` returns null on malformed entries; filter those out so the typed list
      // never contains nulls.
      buttons = (json['buttons'] as List)
          .whereType<Map>()
          .map((m) => FlareLaneNotificationButton.fromJson(m))
          .whereType<FlareLaneNotificationButton>()
          .toList();
    }
    if (json['clickedButtonIndex'] is int) {
      clickedButtonIndex = json['clickedButtonIndex'] as int;
    }
    if (json['clickedButton'] is Map) {
      clickedButton = FlareLaneNotificationButton.fromJson(json['clickedButton'] as Map);
    }
    if (json['clickedUrl'] is String) {
      clickedUrl = json['clickedUrl'] as String?;
    }
  }

  @override
  String toString() {
    return 'FlareLaneNotification{id: $id, title: $title, body: $body, url: $url, imageUrl: $imageUrl, data: $data, buttons: $buttons, clickedButtonIndex: $clickedButtonIndex, clickedButton: $clickedButton, clickedUrl: $clickedUrl}';
  }
}
