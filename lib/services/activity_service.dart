import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/activity.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _activitiesCollection = 'activities';

  Future<List<Activity>> getRecentActivities(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_activitiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Activity.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting recent activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getFeedActivities({int limit = 15}) async {
    try {
      final snapshot = await _firestore
          .collection(_activitiesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Activity.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting feed activities: $e');
      return [];
    }
  }

  Future<String> addActivity(Activity activity) async {
    try {
      final activityJson = activity.toJson();
      activityJson.remove('id');
      
      final docRef = await _firestore.collection(_activitiesCollection).add(activityJson);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding activity: $e');
      rethrow;
    }
  }

  Stream<List<Activity>> getActivitiesStream(String userId, {int limit = 20}) {
    return _firestore
        .collection(_activitiesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Activity.fromJson({...data, 'id': doc.id});
            }).toList());
  }

  Stream<List<Activity>> getFeedStream({int limit = 15}) {
    return _firestore
        .collection(_activitiesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Activity.fromJson({...data, 'id': doc.id});
            }).toList());
  }
}
