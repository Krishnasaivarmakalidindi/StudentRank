import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/resource.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _resourcesCollection = 'resources';

  // MOCK DATA
  final List<Resource> _mockResources = [
    Resource(
      id: 'mock_1',
      title: 'Quantum Mechanics Notes',
      description: 'Comprehensive notes on wave functions, Schrödinger equation, and quantum tunneling. Perfect for undergrads.',
      subject: 'Physics',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_1',
      authorName: 'Dr. Sarah Miller',
      viewCount: 1250,
      downloadCount: 450,
      qualityRating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      reputationImpact: 10,
      improveCount: 2,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Quantum Mechanics',
    ),
    Resource(
      id: 'mock_2',
      title: 'Data Structures Cheat Sheet',
      description: 'Quick reference guide for Arrays, Linked Lists, Trees, Graphs, and Hash Maps. Includes complexity charts.',
      subject: 'Computer Science',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_2',
      authorName: 'Alex Chen',
      viewCount: 3400,
      downloadCount: 1200,
      qualityRating: 4.9,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      reputationImpact: 15,
      improveCount: 5,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Data Structures',
    ),
    Resource(
      id: 'mock_3',
      title: 'Linear Algebra Fundamentals',
      description: 'Matrix operations, Eigenvalues, Eigenvectors, and Vector Spaces explained with examples.',
      subject: 'Mathematics',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_3',
      authorName: 'Prof. David Wilson',
      viewCount: 890,
      downloadCount: 320,
      qualityRating: 4.7,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      reputationImpact: 8,
      improveCount: 1,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Linear Algebra',
    ),
    Resource(
      id: 'mock_4',
      title: 'Thermodynamics Summary',
      description: 'Key laws of thermodynamics, entropy, and heat transfer equations. Exam ready summary.',
      subject: 'Physics',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_1',
      authorName: 'Dr. Sarah Miller',
      viewCount: 600,
      downloadCount: 150,
      qualityRating: 4.5,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      reputationImpact: 7,
      improveCount: 0,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Thermodynamics',
    ),
    Resource(
      id: 'mock_5',
      title: 'Machine Learning Algorithms',
      description: 'Deep dive into Supervised and Unsupervised learning. Regression, SVM, Decision Trees, and K-Means.',
      subject: 'Computer Science',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_4',
      authorName: 'Priya Patel',
      viewCount: 5600,
      downloadCount: 2100,
      qualityRating: 5.0,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      reputationImpact: 20,
      improveCount: 12,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Machine Learning',
    ),
    Resource(
      id: 'mock_6',
      title: 'Calculus II: Integration',
      description: 'Advanced integration techniques, sequences, and series. Includes practice problems.',
      subject: 'Mathematics',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_3',
      authorName: 'Prof. David Wilson',
      viewCount: 1100,
      downloadCount: 400,
      qualityRating: 4.6,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      reputationImpact: 9,
      improveCount: 3,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Calculus',
    ),
    Resource(
      id: 'mock_7',
      title: 'Operating Systems Concepts',
      description: 'Processes, Threads, Scheduling, Deadlocks, and Memory Management. OS internals explained.',
      subject: 'Computer Science',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_2',
      authorName: 'Alex Chen',
      viewCount: 1500,
      downloadCount: 500,
      qualityRating: 4.7,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      reputationImpact: 11,
      improveCount: 4,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Operating Systems',
    ),
    Resource(
      id: 'mock_8',
      title: 'Electromagnetism Basics',
      description: 'Maxwell\'s equations, electric fields, magnetic fields, and electromagnetic waves.',
      subject: 'Physics',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_5',
      authorName: 'James Maxwell',
      viewCount: 950,
      downloadCount: 280,
      qualityRating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      reputationImpact: 10,
      improveCount: 1,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Electromagnetism',
    ),
    Resource(
      id: 'mock_9',
      title: 'Database Management Systems',
      description: 'SQL, Normalization, ACID properties, and Transaction management. Complete DBMS guide.',
      subject: 'Databases',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_4',
      authorName: 'Priya Patel',
      viewCount: 2200,
      downloadCount: 800,
      qualityRating: 4.9,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      reputationImpact: 14,
      improveCount: 6,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Databases',
    ),
    Resource(
      id: 'mock_10',
      title: 'Web Development Bootcamp',
      description: 'HTML, CSS, JavaScript, React, and Node.js. Full stack development path.',
      subject: 'Web Development',
      type: ResourceType.notes,
      fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      authorId: 'mock_author_2',
      authorName: 'Alex Chen',
      viewCount: 4100,
      downloadCount: 1500,
      qualityRating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      reputationImpact: 18,
      improveCount: 9,
      isPlagiarized: false,
      updatedAt: DateTime.now(),
      topic: 'Web Development',
    ),
  ];

  Future<List<Resource>> getAllResources() async {
    try {
      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      
      final dbResources = snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();

      return [..._mockResources, ...dbResources];
    } catch (e) {
      debugPrint('Error getting all resources: $e');
      return _mockResources;
    }
  }

  Future<List<Resource>> getResourcesBySubject(String subject) async {
    try {
      final mockMatches = _mockResources.where((r) => r.subject == subject).toList();

      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final dbResources = snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();

      return [...mockMatches, ...dbResources];
    } catch (e) {
      debugPrint('Error getting resources by subject: $e');
      return _mockResources.where((r) => r.subject == subject).toList();
    }
  }

  Future<List<Resource>> getTrendingResources({int limit = 6}) async {
    try {
      // Return mocked resources sorted by viewCount + db resources
      final sortedMock = List<Resource>.from(_mockResources)
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      try {
          final snapshot = await _firestore
              .collection(_resourcesCollection)
              .orderBy('viewCount', descending: true)
              .orderBy('qualityRating', descending: true)
              .limit(limit)
              .get();
          
          final dbResources = snapshot.docs.map((doc) {
            final data = doc.data();
            return Resource.fromJson({...data, 'id': doc.id});
          }).toList();

          final combined = [...sortedMock.take(limit), ...dbResources];
          // Deduplicate if necessary, but ids are distinct
          return combined.take(limit).toList();
      } catch (dbError) {
           debugPrint('DB error for trending: $dbError');
           return sortedMock.take(limit).toList();
      }
    } catch (e) {
      debugPrint('Error getting trending resources: $e');
      return _mockResources.take(limit).toList();
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
    // Only works for DB resources
    if (resourceId.startsWith('mock_')) return;

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
      
      final mockMatches = _mockResources.where((r) =>
          r.title.toLowerCase().contains(lowerQuery) ||
          r.description.toLowerCase().contains(lowerQuery) ||
          r.subject.toLowerCase().contains(lowerQuery) ||
          (r.topic?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();

      try {
        final snapshot = await _firestore
            .collection(_resourcesCollection)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get();
        
        final dbMatches = snapshot.docs
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
            
        return [...mockMatches, ...dbMatches];

      } catch (dbError) {
        return mockMatches;
      }
    } catch (e) {
      debugPrint('Error searching resources: $e');
      return [];
    }
  }

  Future<Resource?> getResourceById(String id) async {
    if (id.startsWith('mock_')) {
      return _mockResources.firstWhere((r) => r.id == id, orElse: () => _mockResources.first);
    }

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
    if (resourceId.startsWith('mock_')) return;
    try {
      await _firestore.collection(_resourcesCollection).doc(resourceId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  Future<void> incrementDownloadCount(String resourceId) async {
    if (resourceId.startsWith('mock_')) return;
    try {
      await _firestore.collection(_resourcesCollection).doc(resourceId).update({
        'downloadCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing download count: $e');
    }
  }

  Stream<List<Resource>> getResourcesStream({int limit = 20}) {
    // Note: Stream only returns DB resources for simplicity in this hybrid approach
    // If real-time mock data is needed, we'd need to emit it manually.
    // For now, this is acceptable as the main Explore view uses Futures.
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
      final mockMatches = _mockResources.where((r) => r.authorId == authorId).take(limit).toList();

      final snapshot = await _firestore
          .collection(_resourcesCollection)
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final dbResources = snapshot.docs.map((doc) {
        final data = doc.data();
        return Resource.fromJson({...data, 'id': doc.id});
      }).toList();

      return [...mockMatches, ...dbResources];
    } catch (e) {
      debugPrint('Error getting resources by author: $e');
      return [];
    }
  }
}
