import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String? photoUrl;

  // NIAT Academic Identity
  final String? campusId;
  final String? branch;
  final int? year;
  final int? semester;

  // Status flags
  final bool isVerified;
  final bool profileCompleted; // Academic onboarding done
  final bool isGuest;

  // Reputation
  final int reputationScore;

  // Timestamps
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime?
      academicUpdatedAt; // Track when academic fields were last changed

  // Settings
  final Map<String, bool> privacySettings;
  final Map<String, bool> notificationSettings;

  User({
    required this.id,
    required this.name,
    this.email,
    this.photoUrl,
    this.campusId,
    this.branch,
    this.year,
    this.semester,
    this.isVerified = false,
    this.profileCompleted = false,
    this.isGuest = false,
    this.reputationScore = 0,
    required this.createdAt,
    required this.lastLoginAt,
    this.academicUpdatedAt,
    this.privacySettings = const {
      'profileVisible': true,
      'campusOnly': false,
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
        'photoUrl': photoUrl,
        'campusId': campusId,
        'branch': branch,
        'year': year,
        'semester': semester,
        'isVerified': isVerified,
        'profileCompleted': profileCompleted,
        'isGuest': isGuest,
        'reputationScore': reputationScore,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLoginAt': Timestamp.fromDate(lastLoginAt),
        'academicUpdatedAt': academicUpdatedAt != null
            ? Timestamp.fromDate(academicUpdatedAt!)
            : null,
        'privacySettings': privacySettings,
        'notificationSettings': notificationSettings,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    DateTime? parseDateTimeNullable(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Student',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      campusId: json['campusId'] as String?,
      branch: json['branch'] as String?,
      year: json['year'] as int?,
      semester: json['semester'] as int?,
      isVerified: json['isVerified'] as bool? ?? false,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      isGuest: json['isGuest'] as bool? ?? false,
      reputationScore: json['reputationScore'] as int? ?? 0,
      createdAt: parseDateTime(json['createdAt']),
      lastLoginAt: parseDateTime(json['lastLoginAt']),
      academicUpdatedAt: parseDateTimeNullable(json['academicUpdatedAt']),
      privacySettings: (json['privacySettings'] as Map<String, dynamic>?)
              ?.cast<String, bool>() ??
          {
            'profileVisible': true,
            'campusOnly': false,
            'contributionsVisible': true,
          },
      notificationSettings:
          (json['notificationSettings'] as Map<String, dynamic>?)
                  ?.cast<String, bool>() ??
              {
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
    String? photoUrl,
    String? campusId,
    String? branch,
    int? year,
    int? semester,
    bool? isVerified,
    bool? profileCompleted,
    bool? isGuest,
    int? reputationScore,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? academicUpdatedAt,
    Map<String, bool>? privacySettings,
    Map<String, bool>? notificationSettings,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        campusId: campusId ?? this.campusId,
        branch: branch ?? this.branch,
        year: year ?? this.year,
        semester: semester ?? this.semester,
        isVerified: isVerified ?? this.isVerified,
        profileCompleted: profileCompleted ?? this.profileCompleted,
        isGuest: isGuest ?? this.isGuest,
        reputationScore: reputationScore ?? this.reputationScore,
        createdAt: createdAt ?? this.createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        academicUpdatedAt: academicUpdatedAt ?? this.academicUpdatedAt,
        privacySettings: privacySettings ?? this.privacySettings,
        notificationSettings: notificationSettings ?? this.notificationSettings,
      );

  /// Check if academic identity can be updated (30-day lock)
  bool get canUpdateAcademicIdentity {
    if (academicUpdatedAt == null) return true;
    return DateTime.now().difference(academicUpdatedAt!).inDays >= 30;
  }

  /// Days remaining until academic identity can be updated
  int get daysUntilAcademicUnlock {
    if (canUpdateAcademicIdentity) return 0;
    return 30 - DateTime.now().difference(academicUpdatedAt!).inDays;
  }
}
