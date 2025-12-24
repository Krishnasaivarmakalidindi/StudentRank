import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/study_group.dart';

class StudyGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _groupsCollection = 'study_groups';

  Future<List<StudyGroup>> getAllGroups() async {
    try {
      final snapshot = await _firestore
          .collection(_groupsCollection)
          .orderBy('memberCount', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudyGroup.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting all groups: $e');
      return [];
    }
  }

  Future<List<StudyGroup>> getMyGroups(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_groupsCollection)
          .where('members', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudyGroup.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting my groups: $e');
      return [];
    }
  }

  Future<String> createGroup(StudyGroup group) async {
    try {
      final groupJson = group.toJson();
      groupJson.remove('id');
      
      final docRef = await _firestore.collection(_groupsCollection).add(groupJson);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating group: $e');
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final doc = await _firestore.collection(_groupsCollection).doc(groupId).get();
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final group = StudyGroup.fromJson({...data, 'id': doc.id});
      
      if (group.members.contains(userId)) return;
      
      await _firestore.collection(_groupsCollection).doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
        'memberCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error joining group: $e');
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_groupsCollection).doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error leaving group: $e');
      rethrow;
    }
  }

  Future<StudyGroup?> getGroupById(String id) async {
    try {
      final doc = await _firestore.collection(_groupsCollection).doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return StudyGroup.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting group by ID: $e');
      return null;
    }
  }

  Future<List<StudyGroup>> getGroupsBySubject(String subject) async {
    try {
      final snapshot = await _firestore
          .collection(_groupsCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('memberCount', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudyGroup.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting groups by subject: $e');
      return [];
    }
  }

  Stream<List<StudyGroup>> getGroupsStream({int limit = 20}) {
    return _firestore
        .collection(_groupsCollection)
        .orderBy('memberCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return StudyGroup.fromJson({...data, 'id': doc.id});
            }).toList());
  }

  Stream<StudyGroup?> getGroupStream(String groupId) {
    return _firestore.collection(_groupsCollection).doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return StudyGroup.fromJson({...data, 'id': doc.id});
    });
  }
}
