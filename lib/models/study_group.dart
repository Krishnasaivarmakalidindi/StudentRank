import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String subject; // Kept for backward compatibility, mapped to category if needed
  final String category;
  final String college;
  final int memberCount;
  final int messageCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isPrivate;
  final String adminId; // createdBy
  final List<String> members;
  final List<String> resourceIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;
  final String? avatar;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.category,
    required this.college,
    required this.memberCount,
    this.messageCount = 0,
    this.lastMessage,
    this.lastMessageTime,
    required this.isPrivate,
    required this.adminId,
    required this.members,
    required this.resourceIds,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.avatar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'subject': subject,
        'category': category,
        'college': college,
        'memberCount': memberCount,
        'messageCount': messageCount,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
        'isPrivate': isPrivate,
        'adminId': adminId,
        'members': members,
        'resourceIds': resourceIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'isDefault': isDefault,
        'avatar': avatar,
        'createdBy': adminId, // Sync adminId with createdBy
      };

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return StudyGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      subject: json['subject'] as String? ?? (json['category'] as String? ?? ''),
      category: json['category'] as String? ?? (json['subject'] as String? ?? ''),
      college: json['college'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
      messageCount: json['messageCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null ? parseDateTime(json['lastMessageTime']) : null,
      isPrivate: json['isPrivate'] as bool? ?? false,
      adminId: json['adminId'] as String? ?? (json['createdBy'] as String? ?? ''),
      members: (json['members'] as List?)?.cast<String>() ?? [],
      resourceIds: (json['resourceIds'] as List?)?.cast<String>() ?? [],
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      isDefault: json['isDefault'] as bool? ?? false,
      avatar: json['avatar'] as String?,
    );
  }

  StudyGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? subject,
    String? category,
    String? college,
    int? memberCount,
    int? messageCount,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isPrivate,
    String? adminId,
    List<String>? members,
    List<String>? resourceIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    String? avatar,
  }) =>
      StudyGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        subject: subject ?? this.subject,
        category: category ?? this.category,
        college: college ?? this.college,
        memberCount: memberCount ?? this.memberCount,
        messageCount: messageCount ?? this.messageCount,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        isPrivate: isPrivate ?? this.isPrivate,
        adminId: adminId ?? this.adminId,
        members: members ?? this.members,
        resourceIds: resourceIds ?? this.resourceIds,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDefault: isDefault ?? this.isDefault,
        avatar: avatar ?? this.avatar,
      );
}
