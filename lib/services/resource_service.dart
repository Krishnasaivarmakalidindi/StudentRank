import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/resource.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _resourcesCollection = 'resources';

  Future<List<Resource>> getAllResources() async {
    try {
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting all resources: $e');
      return [];
    }
  }

  Future<List<Resource>> getResourcesBySubject(String subject) async {
    try {
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting resources by subject: $e');
      return [];
    }
  }

  Future<List<Resource>> getTrendingResources({int limit = 6}) async {
    try {
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .orderBy('viewCount', descending: true)
          .orderBy('qualityRating', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting trending resources: $e');
      return [];
    }
  }

  Future<String> uploadResource(Resource resource) async {
    try {
      final resourceJson = resource.toJson();
      resourceJson.remove('id');
      
      final docRef = await _firestore.collection(_resourcesCollection).add(resourceJson);
      return docRef.id;
    } catch (e) {
      debugPrint('Error uploading resource: $e');
      rethrow;
    }
  }

  Future<void> improveResource(String resourceId, String improvements) async {
    try {
      final doc = await _firestore.collection(_resourcesCollection).doc(resourceId).get();
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final resource = Resource.fromJson({...data, 'id': doc.id});
      
      await _firestore.collection(_resourcesCollection).doc(resourceId).update({
        'improveCount': resource.improveCount + 1,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error improving resource: $e');
      rethrow;
    }
  }

  Future<List<Resource>> searchResources(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return Resource.fromJson({...data, 'id': doc.id});
          })
          .where((r) =>
              r.title.toLowerCase().contains(lowerQuery) ||
              r.description.toLowerCase().contains(lowerQuery) ||
              r.subject.toLowerCase().contains(lowerQuery) ||
              (r.topic?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    } catch (e) {
      debugPrint('Error searching resources: $e');
      return [];
    }
  }

  Future<Resource?> getResourceById(String id) async {
    try {
      final doc = await _firestore.collection(_resourcesCollection).doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return Resource.fromJson({...data, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting resource by ID: $e');
      return null;
    }
  }

  Future<void> incrementViewCount(String resourceId) async {
    try {
      await _firestore.collection(_resourcesCollection).doc(resourceId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  Future<void> incrementDownloadCount(String resourceId) async {
    try {
      await _firestore.collection(_resourcesCollection).doc(resourceId).update({
        'downloadCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing download count: $e');
    }
  }

  Stream<List<Resource>> getResourcesStream({int limit = 20}) {
    return _firestore
        .collection(_resourcesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Resource.fromJson({...data, 'id': doc.id});
            }).toList());
  }

  Future<List<Resource>> getResourcesByAuthor(String authorId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting resources by author: $e');
      return [];
    }
  }
}
