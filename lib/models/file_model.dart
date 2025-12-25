import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String fileId;
  final String groupId;
  final String userId;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String fileUrl;
  final String description;
  final DateTime uploadedAt;
  final String uploaderName;
  final int downloads;

  FileModel({
    required this.fileId,
    required this.groupId,
    required this.userId,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.fileUrl,
    required this.description,
    required this.uploadedAt,
    required this.uploaderName,
    this.downloads = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'groupId': groupId,
      'userId': userId,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'description': description,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploaderName': uploaderName,
      'downloads': downloads,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return FileModel(
      fileId: map['fileId'] ?? '',
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      description: map['description'] ?? '',
      uploadedAt: map['uploadedAt'] != null ? parseDateTime(map['uploadedAt']) : DateTime.now(),
      uploaderName: map['uploaderName'] ?? 'Unknown',
      downloads: map['downloads'] ?? 0,
    );
  }
}
