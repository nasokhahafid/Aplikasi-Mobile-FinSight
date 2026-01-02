class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isDone;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isDone = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      isDone: json['is_done'] == 1 || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_done': isDone,
    };
  }
}
