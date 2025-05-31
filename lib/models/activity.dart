class Activity {
  final int id;
  final String description;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Activity.fromSqlMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
