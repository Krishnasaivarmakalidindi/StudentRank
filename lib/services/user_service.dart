import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Helper to check if a user is a guest based on their model or other logic
  // Since we are storing isGuest in Firestore, this is a model check usually.
  bool isGuestUser(User user) {
    return user.isGuest;
  }

  // Get User by ID
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

  // Create or Overwrite User
  Future<void> createUser(User user) async {
    try {
      final userJson = user.toJson();
      userJson.remove('id'); // ID is the document key
      await _firestore.collection(_usersCollection).doc(user.id).set(userJson);
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Update generic profile fields
  Future<void> updateProfile(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final userJson = updatedUser.toJson();
      userJson.remove('id');
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(userJson);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateReputationScore(String userId, int change) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      final newScore = user.reputationScore + change;
      final newLevel = _calculateLevel(newScore);

      await _firestore.collection(_usersCollection).doc(userId).update({
        'reputationScore': newScore,
        'level': newLevel,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating reputation score: $e');
      rethrow;
    }
  }

  int _calculateLevel(int reputation) {
    if (reputation < 500) return 1;
    if (reputation < 1000) return 2;
    if (reputation < 2000) return 3;
    if (reputation < 3500) return 4;
    if (reputation < 5500) return 5;
    if (reputation < 8000) return 6;
    return 7;
  }

  Future<void> addBadge(String userId, Badge badge) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      final badges = List<Badge>.from(user.badges)..add(badge);

      await _firestore.collection(_usersCollection).doc(userId).update({
        'badges': badges.map((b) => b.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error adding badge: $e');
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final snapshot =
          await _firestore.collection(_usersCollection).limit(100).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<List<User>> getTopContributors(
      {String? subject, int limit = 10}) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Filter out guest users from leaderboards
      query = query.where('isGuest', isNotEqualTo: true);

      if (subject != null) {
        query = query.where('subjects', arrayContains: subject);
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

  // Updates email in Firestore only - Auth moved to AuthService
  Future<void> updateEmailInFirestore(String userId, String newEmail) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'email': newEmail,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating email in firestore: $e');
      rethrow;
    }
  }

  // Delete from Firestore only - Auth moved to AuthService
  Future<void> deleteUserDocument(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      debugPrint('Error deleting user doc: $e');
      rethrow;
    }
  }

  Future<void> updatePrivacySettings(
      String userId, Map<String, bool> settings) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'privacySettings': settings,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationSettings(
      String userId, Map<String, bool> settings) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'notificationSettings': settings,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }
}
