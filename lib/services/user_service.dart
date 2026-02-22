import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // ─── Get User by ID ───
  Future<User?> getUserById(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return User.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      rethrow;
    }
  }

  // ─── Create User Document ───
  Future<void> createUser(User user) async {
    try {
      final userJson = user.toJson();
      userJson.remove('id');
      await _firestore.collection(_usersCollection).doc(user.id).set(userJson);
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // ─── Check if user document exists ───
  Future<bool> userExists(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  // ─── Update Profile ───
  Future<void> updateProfile(User user) async {
    try {
      final userJson = user.toJson();
      userJson.remove('id');
      userJson['lastLoginAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(userJson);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // ─── Complete Academic Onboarding ───
  Future<void> completeOnboarding({
    required String userId,
    required String campusId,
    required String branch,
    required int year,
    required int semester,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'campusId': campusId,
        'branch': branch,
        'year': year,
        'semester': semester,
        'profileCompleted': true,
        'academicUpdatedAt': Timestamp.fromDate(DateTime.now()),
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      rethrow;
    }
  }

  // ─── Update Academic Identity (with 30-day lock check) ───
  Future<void> updateAcademicIdentity({
    required User user,
    required String campusId,
    required String branch,
    required int year,
    required int semester,
  }) async {
    if (!user.canUpdateAcademicIdentity) {
      throw Exception(
          'Academic identity can only be updated once every 30 days. '
          '${user.daysUntilAcademicUnlock} days remaining.');
    }

    try {
      await _firestore.collection(_usersCollection).doc(user.id).update({
        'campusId': campusId,
        'branch': branch,
        'year': year,
        'semester': semester,
        'academicUpdatedAt': Timestamp.fromDate(DateTime.now()),
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating academic identity: $e');
      rethrow;
    }
  }

  // ─── Update Last Login ───
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // ─── Update Reputation Score ───
  Future<void> updateReputationScore(String userId, int change) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      final newScore = user.reputationScore + change;

      await _firestore.collection(_usersCollection).doc(userId).update({
        'reputationScore': newScore,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating reputation score: $e');
      rethrow;
    }
  }

  // ─── Get Top Contributors (campus-level segmentation) ───
  Future<List<User>> getTopContributors({
    String? campusId,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Filter out guests
      query = query.where('isGuest', isEqualTo: false);

      // Campus-level segmentation
      if (campusId != null) {
        query = query.where('campusId', isEqualTo: campusId);
      }

      query = query.orderBy('reputationScore', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return User.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting top contributors: $e');
      return [];
    }
  }

  // ─── User Stream ───
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return User.fromJson({...data, 'id': doc.id});
    });
  }

  // ─── Update Email in Firestore ───
  Future<void> updateEmailInFirestore(String userId, String newEmail) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'email': newEmail,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating email in firestore: $e');
      rethrow;
    }
  }

  // ─── Delete User Document ───
  Future<void> deleteUserDocument(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user doc: $e');
      rethrow;
    }
  }

  // ─── Privacy Settings ───
  Future<void> updatePrivacySettings(
      String userId, Map<String, bool> settings) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'privacySettings': settings,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      rethrow;
    }
  }

  // ─── Notification Settings ───
  Future<void> updateNotificationSettings(
      String userId, Map<String, bool> settings) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'notificationSettings': settings,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }
}
