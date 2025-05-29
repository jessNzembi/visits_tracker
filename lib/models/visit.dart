class Visit {
  final int id;
  final int customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<int> activitiesDone;
  final DateTime? createdAt;

  // Not part of backend, just for UI
  List<String>? activityDescriptions;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    this.createdAt,
    this.activityDescriptions,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      customerId: json['customer_id'],
      visitDate: DateTime.parse(json['visit_date']),
      status: json['status'],
      location: json['location'],
      notes: json['notes'],
      activitiesDone:
          (json['activities_done'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson({bool forCreation = false}) {
    final map = {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone.map((id) => id.toString()).toList(),
    };
    if (!forCreation) {
      map['id'] = id;
      if (createdAt != null) {
        map['created_at'] = createdAt!.toIso8601String();
      }
    }
    return map;
  }
}
