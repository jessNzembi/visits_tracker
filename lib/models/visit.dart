import 'dart:convert';

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
  String customerName;

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
    this.customerName = "",
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

  Map<String, dynamic> toJson() {
    final map = {
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone.map((id) => id.toString()).toList(),
    };
    return map;
  }

  Map<String, dynamic> toSqlMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date':
          visitDate.millisecondsSinceEpoch,
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': jsonEncode(activitiesDone),
      'created_at':
          createdAt?.millisecondsSinceEpoch,
      'activity_descriptions':
          activityDescriptions != null
              ? jsonEncode(activityDescriptions)
              : null,
      'customer_name': customerName,
    };
  }

  factory Visit.fromSqlMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      customerId: map['customer_id'],
      visitDate: DateTime.fromMillisecondsSinceEpoch(map['visit_date']),
      status: map['status'],
      location: map['location'],
      notes: map['notes'] ?? '',
      activitiesDone:
          map['activities_done'] != null &&
                  map['activities_done'].toString().isNotEmpty
              ? List<int>.from(
                jsonDecode(
                  map['activities_done'],
                ).map((e) => int.tryParse(e.toString()) ?? 0),
              )
              : [],
      createdAt:
          map['created_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
              : null,
      activityDescriptions:
          map['activity_descriptions'] != null &&
                  map['activity_descriptions'].toString().isNotEmpty
              ? List<String>.from(jsonDecode(map['activity_descriptions']))
              : null,
      customerName: map['customer_name'] ?? "",
    );
  }

}
extension VisitCopyWith on Visit {
  Visit copyWith({
    int? id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<int>? activitiesDone,
    DateTime? createdAt,
    List<String>? activityDescriptions,
    String? customerName,
  }) {
    return Visit(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activitiesDone: activitiesDone ?? this.activitiesDone,
      createdAt: createdAt ?? this.createdAt,
      activityDescriptions: activityDescriptions ?? this.activityDescriptions,
      customerName: customerName ?? this.customerName,
    );
  }
}
