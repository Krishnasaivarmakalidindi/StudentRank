import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String subject;
  final String college;
  final int memberCount;
  final bool isPrivate;
  final String adminId;
  final List<String> members;
  final List<String> resourceIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.college,
    required this.memberCount,
    required this.isPrivate,
    required this.adminId,
    required this.members,
    required this.resourceIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'subject': subject,
        'college': college,
        'memberCount': memberCount,
        'isPrivate': isPrivate,
        'adminId': adminId,
        'members': members,
        'resourceIds': resourceIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return StudyGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      subject: json['subject'] as String,
      college: json['college'] as String,
      memberCount: json['memberCount'] as int,
      isPrivate: json['isPrivate'] as bool,
      adminId: json['adminId'] as String,
      members: (json['members'] as List).cast<String>(),
      resourceIds: (json['resourceIds'] as List).cast<String>(),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  StudyGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? subject,
    String? college,
    int? memberCount,
    bool? isPrivate,
    String? adminId,
    List<String>? members,
    List<String>? resourceIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      StudyGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        subject: subject ?? this.subject,
        college: college ?? this.college,
        memberCount: memberCount ?? this.memberCount,
        isPrivate: isPrivate ?? this.isPrivate,
        adminId: adminId ?? this.adminId,
        members: members ?? this.members,
        resourceIds: resourceIds ?? this.resourceIds,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
