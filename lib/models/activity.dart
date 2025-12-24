import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  upload,
  improve,
  answer,
  achievement,
  join,
}

class Activity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final int reputationChange;
  final String? resourceId;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.reputationChange,
    this.resourceId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'description': description,
        'reputationChange': reputationChange,
        'resourceId': resourceId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Activity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: ActivityType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      reputationChange: json['reputationChange'] as int,
      resourceId: json['resourceId'] as String?,
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
