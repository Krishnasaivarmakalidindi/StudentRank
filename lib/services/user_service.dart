import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:studentrank/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn();
  
  static const String _usersCollection = 'users';

  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return User.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;
      return await getCurrentUser();
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In flow
      final gsi.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null; 
      }

      // 2. Obtain the auth details from the request
      final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      // 5. Check if user exists in Firestore
      final doc = await _firestore.collection(_usersCollection).doc(firebaseUser.uid).get();

      if (doc.exists) {
        // Existing user
        final data = doc.data()!;
        return User.fromJson({...data, 'id': doc.id});
      } else {
        // New user - create profile
        final newUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? "Student",
          email: firebaseUser.email ?? "",
          joinedDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: false,
          profileCompleted: true, // Assume minimal profile is complete
          reputationScore: 0,
          collegeRank: 0,
          level: 1,
          subjects: [],
          badges: [],
          profileImageUrl: firebaseUser.photoURL,
        );

        await createUser(newUser);
        return newUser;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) return null;

      final newUser = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
        profileCompleted: true,
        reputationScore: 0,
        collegeRank: 0,
        level: 1,
        subjects: [],
        badges: [],
      );

      await createUser(newUser);
      return newUser;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<User?> signInAnonymously(String name, String educationLevel) async {
    try {
      final credential = await _auth.signInAnonymously();
      if (credential.user == null) return null;

      final newUser = User(
        id: credential.user!.uid,
        name: name,
        educationLevel: educationLevel,
        isGuest: true,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileCompleted: true,
        reputationScore: 0,
        collegeRank: 0,
        level: 1,
        subjects: [],
        badges: [],
      );

      await createUser(newUser);
      return newUser;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  Future<User?> createDemoUser() async {
    try {
      // For demo, we still use anonymous auth so they have a valid UID,
      // but we mark them as isDemo in Firestore
      final credential = await _auth.signInAnonymously();
      if (credential.user == null) return null;

      final demoUser = User(
        id: credential.user!.uid,
        name: "Demo User",
        isDemo: true,
        profileCompleted: true,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reputationScore: 1250, // Pre-filled reputation
        level: 3,
        collegeRank: 42,
        collegeName: "Demo University",
        educationLevel: "Undergraduate",
        bio: "Exploring StudentRank capabilities.",
        subjects: ["Computer Science", "Mathematics"],
        badges: [
          Badge(
            id: "demo_badge_1",
            name: "Early Adopter",
            description: "Joined during beta",
            iconName: "star",
            earnedDate: DateTime.now(),
          ),
          Badge(
            id: "demo_badge_2",
            name: "First Quiz",
            description: "Completed first quiz",
            iconName: "quiz",
            earnedDate: DateTime.now(),
          )
        ],
      );

      await createUser(demoUser);
      return demoUser;
    } catch (e) {
      debugPrint('Error creating demo user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Even if Google sign out fails, we want to ensure Firebase auth is cleared
      await _auth.signOut();
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return User.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> createUser(User user) async {
    try {
      final userJson = user.toJson();
      userJson.remove('id'); // Firestore uses doc ID
      await _firestore.collection(_usersCollection).doc(user.id).set(userJson);
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final userJson = updatedUser.toJson();
      userJson.remove('id');
      await _firestore.collection(_usersCollection).doc(user.id).update(userJson);
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
      final snapshot = await _firestore.collection(_usersCollection).limit(100).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<List<User>> getTopContributors({String? subject, int limit = 10}) async {
    try {
      Query query = _firestore.collection(_usersCollection);
      
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
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return User.fromJson({...data, 'id': doc.id});
    });
  }

  Future<void> changeEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate first
      final email = user.email;
      if (email == null) throw Exception('Current user has no email');
      
      final cred = auth.EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(cred);

      // Update email in Auth
      await user.verifyBeforeUpdateEmail(newEmail);
      
      // Update email in Firestore
      await _firestore.collection(_usersCollection).doc(user.uid).update({
        'email': newEmail,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error changing email: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final email = user.email;
      if (email == null) throw Exception('Current user has no email');

      final cred = auth.EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final email = user.email;
      if (email != null) {
         final cred = auth.EmailAuthProvider.credential(email: email, password: password);
         await user.reauthenticateWithCredential(cred);
      }

      // Delete from Firestore
      await _firestore.collection(_usersCollection).doc(user.uid).delete();
      
      // Delete from Auth
      await user.delete();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  Future<void> updatePrivacySettings(String userId, Map<String, bool> settings) async {
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

  Future<void> updateNotificationSettings(String userId, Map<String, bool> settings) async {
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
