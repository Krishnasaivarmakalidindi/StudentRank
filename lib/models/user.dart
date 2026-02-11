import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String? collegeName;
  final String? educationLevel; // School, UG, PG, Other
  final bool isVerified;
  final bool isDemo;
  final bool isGuest;
  final bool profileCompleted;
  final String? profileImageUrl;
  final String? bio;
  final int reputationScore;
  final int collegeRank;
  final int level;
  final DateTime joinedDate;
  final List<String> subjects;
  final List<Badge> badges;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, bool> privacySettings;
  final Map<String, bool> notificationSettings;

  User({
    required this.id,
    required this.name,
    this.email,
    this.collegeName,
    this.educationLevel,
    this.isVerified = false,
    this.isDemo = false,
    this.isGuest = false,
    this.profileCompleted = false,
    this.profileImageUrl,
    this.bio,
    this.reputationScore = 0,
    this.collegeRank = 0,
    this.level = 1,
    required this.joinedDate,
    this.subjects = const [],
    this.badges = const [],
    required this.createdAt,
    required this.updatedAt,
    this.privacySettings = const {
      'profileVisible': true,
      'collegeOnly': false,
      'contributionsVisible': true,
    },
    this.notificationSettings = const {
      'pushActivity': true,
      'pushReputation': true,
      'pushGroups': true,
      'emailSummaries': true,
      'emailAlerts': true,
    },
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'collegeName': collegeName,
        'educationLevel': educationLevel,
        'isVerified': isVerified,
        'isDemo': isDemo,
        'isGuest': isGuest,
        'profileCompleted': profileCompleted,
        'profileImageUrl': profileImageUrl,
        'bio': bio,
        'reputationScore': reputationScore,
        'collegeRank': collegeRank,
        'level': level,
        'joinedDate': Timestamp.fromDate(joinedDate),
        'subjects': subjects,
        'badges': badges.map((b) => b.toJson()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'privacySettings': privacySettings,
        'notificationSettings': notificationSettings,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      collegeName: json['collegeName'] as String?,
      educationLevel: json['educationLevel'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isDemo: json['isDemo'] as bool? ?? false,
      isGuest: json['isGuest'] as bool? ?? false,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      reputationScore: json['reputationScore'] as int? ?? 0,
      collegeRank: json['collegeRank'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      joinedDate: parseDateTime(json['joinedDate']),
      subjects: (json['subjects'] as List?)?.cast<String>() ?? [],
      badges: (json['badges'] as List?)
              ?.map((b) => Badge.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      privacySettings: (json['privacySettings'] as Map<String, dynamic>?)?.cast<String, bool>() ?? {
        'profileVisible': true,
        'collegeOnly': false,
        'contributionsVisible': true,
      },
      notificationSettings: (json['notificationSettings'] as Map<String, dynamic>?)?.cast<String, bool>() ?? {
        'pushActivity': true,
        'pushReputation': true,
        'pushGroups': true,
        'emailSummaries': true,
        'emailAlerts': true,
      },
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? collegeName,
    String? educationLevel,
    bool? isVerified,
    bool? isDemo,
    bool? isGuest,
    bool? profileCompleted,
    String? profileImageUrl,
    String? bio,
    int? reputationScore,
    int? collegeRank,
    int? level,
    DateTime? joinedDate,
    List<String>? subjects,
    List<Badge>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? privacySettings,
    Map<String, bool>? notificationSettings,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        collegeName: collegeName ?? this.collegeName,
        educationLevel: educationLevel ?? this.educationLevel,
        isVerified: isVerified ?? this.isVerified,
        isDemo: isDemo ?? this.isDemo,
        isGuest: isGuest ?? this.isGuest,
        profileCompleted: profileCompleted ?? this.profileCompleted,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        bio: bio ?? this.bio,
        reputationScore: reputationScore ?? this.reputationScore,
        collegeRank: collegeRank ?? this.collegeRank,
        level: level ?? this.level,
        joinedDate: joinedDate ?? this.joinedDate,
        subjects: subjects ?? this.subjects,
        badges: badges ?? this.badges,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        privacySettings: privacySettings ?? this.privacySettings,
        notificationSettings: notificationSettings ?? this.notificationSettings,
      );
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime earnedDate;
  final String? subject;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.earnedDate,
    this.subject,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconName': iconName,
        'earnedDate': Timestamp.fromDate(earnedDate),
        'subject': subject,
      };

  factory Badge.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      earnedDate: parseDateTime(json['earnedDate']),
      subject: json['subject'] as String?,
    );
  }
}
