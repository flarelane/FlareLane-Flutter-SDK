class InAppMessage {
  late String id;

  InAppMessage(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'] as String;
  }

  @override
  String toString() {
    return 'InAppMessage{id: $id}';
  }
}
