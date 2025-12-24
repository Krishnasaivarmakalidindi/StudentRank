import 'package:cloud_firestore/cloud_firestore.dart';

enum ResourceType {
  notes,
  researchPaper,
}

class Resource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String subject;
  final String? topic;
  final String authorId;
  final String authorName;
  final double qualityRating;
  final int reputationImpact;
  final int viewCount;
  final int downloadCount;
  final int improveCount;
  final String? fileUrl;
  final List<String> attachmentUrls;
  final String? textContent;
  final String? thumbnailUrl;
  final bool isPlagiarized;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.subject,
    this.topic,
    required this.authorId,
    required this.authorName,
    required this.qualityRating,
    required this.reputationImpact,
    required this.viewCount,
    required this.downloadCount,
    required this.improveCount,
    this.fileUrl,
    this.attachmentUrls = const [],
    this.textContent,
    this.thumbnailUrl,
    required this.isPlagiarized,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'subject': subject,
        'topic': topic,
        'authorId': authorId,
        'authorName': authorName,
        'qualityRating': qualityRating,
        'reputationImpact': reputationImpact,
        'viewCount': viewCount,
        'downloadCount': downloadCount,
        'improveCount': improveCount,
        'fileUrl': fileUrl,
        'attachmentUrls': attachmentUrls,
        'textContent': textContent,
        'thumbnailUrl': thumbnailUrl,
        'isPlagiarized': isPlagiarized,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory Resource.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ResourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResourceType.notes,
      ),
      subject: json['subject'] as String,
      topic: json['topic'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      qualityRating: (json['qualityRating'] as num).toDouble(),
      reputationImpact: json['reputationImpact'] as int,
      viewCount: json['viewCount'] as int,
      downloadCount: json['downloadCount'] as int,
      improveCount: json['improveCount'] as int,
      fileUrl: json['fileUrl'] as String?,
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      textContent: json['textContent'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isPlagiarized: json['isPlagiarized'] as bool,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    ResourceType? type,
    String? subject,
    String? topic,
    String? authorId,
    String? authorName,
    double? qualityRating,
    int? reputationImpact,
    int? viewCount,
    int? downloadCount,
    int? improveCount,
    String? fileUrl,
    List<String>? attachmentUrls,
    String? textContent,
    String? thumbnailUrl,
    bool? isPlagiarized,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Resource(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        subject: subject ?? this.subject,
        topic: topic ?? this.topic,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName,
        qualityRating: qualityRating ?? this.qualityRating,
        reputationImpact: reputationImpact ?? this.reputationImpact,
        viewCount: viewCount ?? this.viewCount,
        downloadCount: downloadCount ?? this.downloadCount,
        improveCount: improveCount ?? this.improveCount,
        fileUrl: fileUrl ?? this.fileUrl,
        attachmentUrls: attachmentUrls ?? this.attachmentUrls,
        textContent: textContent ?? this.textContent,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        isPlagiarized: isPlagiarized ?? this.isPlagiarized,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
