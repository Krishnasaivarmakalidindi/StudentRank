import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/study_group.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'study_groups';

  // Singleton pattern (optional but good practice)
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  /// Initialize the 8 default groups if they don't exist
  Future<void> initializeDefaultGroups() async {
    try {
      final WriteBatch batch = _firestore.batch();
      bool hasUpdates = false;

      final List<Map<String, dynamic>> defaultGroups = [
        {
          'id': 'data-science-ml',
          'name': 'Data Science & Machine Learning',
          'category': 'Computer Science',
          'description': 'Explore ML algorithms, data analysis, and AI applications. Share projects and learn together.',
        },
        {
          'id': 'mathematics-solvers',
          'name': 'Mathematics Problem Solvers',
          'category': 'Mathematics',
          'description': 'For math enthusiasts tackling calculus, linear algebra, differential equations, and more. Daily problem challenges.',
        },
        {
          'id': 'circuit-design',
          'name': 'Circuit Design & Analysis Hub',
          'category': 'Electrical Engineering',
          'description': 'For electrical engineering students focusing on circuit theory, electronics, and PCB design. Share projects and schematics.',
        },
        {
          'id': 'quantum-physics',
          'name': 'Quantum Physics Discussion',
          'category': 'Physics',
          'description': 'Deep dive into quantum mechanics, quantum computing, and modern physics. Regular problem-solving sessions.',
        },
        {
          'id': 'web-development',
          'name': 'Web Development Masters',
          'category': 'Computer Science',
          'description': 'Master frontend, backend, and full-stack web development. Share code snippets, projects, and best practices.',
        },
        {
          'id': 'competitive-programming',
          'name': 'Competitive Programming',
          'category': 'Computer Science',
          'description': 'Practice coding problems, algorithms, and competitive programming. Daily challenges and solutions.',
        },
        {
          'id': 'android-development',
          'name': 'Android Development',
          'category': 'Computer Science',
          'description': 'Build amazing Android apps. Share tutorials, libraries, and projects with fellow developers.',
        },
        {
          'id': 'ai-blockchain',
          'name': 'AI & Blockchain',
          'category': 'Emerging Tech',
          'description': 'Explore artificial intelligence, blockchain technology, Web3, and decentralized applications.',
        },
      ];

      for (var groupData in defaultGroups) {
        final docRef = _firestore.collection(_collection).doc(groupData['id']);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          final now = Timestamp.now();
          final studyGroup = StudyGroup(
            id: groupData['id'],
            name: groupData['name'],
            description: groupData['description'],
            subject: groupData['category'],
            category: groupData['category'],
            college: 'Global', // Default college
            memberCount: 0,
            messageCount: 0,
            isPrivate: false,
            adminId: 'system',
            members: [],
            resourceIds: [],
            createdAt: now.toDate(),
            updatedAt: now.toDate(),
            isDefault: true,
          );
          
          batch.set(docRef, studyGroup.toJson());
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
        debugPrint('Default groups initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing default groups: $e');
    }
  }

  /// Get stream of all groups ordered by member count
  Stream<List<StudyGroup>> getAllGroups() {
    return _firestore
        .collection(_collection)
        .orderBy('memberCount', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is set
        return StudyGroup.fromJson(data);
      }).toList();
    });
  }

  /// Get groups where user is a member
  Stream<List<StudyGroup>> getUserGroups(String userId) {
    return _firestore
        .collection(_collection)
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StudyGroup.fromJson(data);
      }).toList();
    });
  }

  /// Join a group
  Future<void> joinGroup(String groupId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Check if already member
      final isMember = await isUserMember(groupId, userId);
      if (isMember) return; // Already a member

      await _firestore.collection(_collection).doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error joining group: $e');
      rethrow;
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error leaving group: $e');
      rethrow;
    }
  }

  /// Create a new group
  Future<String> createGroup({
    required String name,
    required String description,
    required String category,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    try {
      final now = DateTime.now();
      final newGroupRef = _firestore.collection(_collection).doc();
      
      final newGroup = StudyGroup(
        id: newGroupRef.id,
        name: name,
        description: description,
        category: category,
        subject: category, // Mapping category to subject
        college: 'User Created', // Default or could be optional
        memberCount: 1, // Creator is first member
        messageCount: 0,
        isPrivate: false,
        adminId: userId,
        members: [userId],
        resourceIds: [],
        createdAt: now,
        updatedAt: now,
        isDefault: false,
      );

      await newGroupRef.set(newGroup.toJson());
      return newGroupRef.id;
    } catch (e) {
      debugPrint('Error creating group: $e');
      rethrow;
    }
  }

  /// Check if user is member
  Future<bool> isUserMember(String groupId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      if (!doc.exists) return false;
      
      final List<dynamic> members = doc.data()?['members'] ?? [];
      return members.contains(userId);
    } catch (e) {
      debugPrint('Error checking membership: $e');
      return false;
    }
  }

  // Helper to get single group stream (needed for details screen)
  Stream<StudyGroup?> getGroupStream(String groupId) {
    return _firestore.collection(_collection).doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return StudyGroup.fromJson(data);
    });
  }
}
