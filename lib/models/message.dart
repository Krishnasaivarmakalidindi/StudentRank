import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String groupId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String messageText;
  final String? attachmentUrl;
  final String? attachmentType; // 'image', 'file', 'text'
  final DateTime timestamp;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, int> reactions;

  Message({
    required this.messageId,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.messageText,
    this.attachmentUrl,
    this.attachmentType,
    required this.timestamp,
    this.isEdited = false,
    this.editedAt,
    this.reactions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'groupId': groupId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'messageText': messageText,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'reactions': reactions,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Message(
      messageId: map['messageId'] ?? '',
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      userAvatar: map['userAvatar'],
      messageText: map['messageText'] ?? '',
      attachmentUrl: map['attachmentUrl'],
      attachmentType: map['attachmentType'],
      timestamp: map['timestamp'] != null ? parseDateTime(map['timestamp']) : DateTime.now(),
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? parseDateTime(map['editedAt']) : null,
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
    );
  }
}
