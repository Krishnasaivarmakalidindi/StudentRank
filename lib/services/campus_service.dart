import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studentrank/models/campus.dart';

class CampusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _campusesCollection = 'campuses';

  /// Cached campuses to avoid redundant reads
  List<Campus>? _cachedCampuses;

  /// Fetch all active campuses from Firestore
  Future<List<Campus>> getActiveCampuses() async {
    if (_cachedCampuses != null) return _cachedCampuses!;

    try {
      final snapshot = await _firestore
          .collection(_campusesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      _cachedCampuses = snapshot.docs
          .map((doc) => Campus.fromJson(doc.data(), doc.id))
          .toList();

      return _cachedCampuses!;
    } catch (e) {
      debugPrint('Error fetching campuses: $e');
      return [];
    }
  }

  /// Get a single campus by ID
  Future<Campus?> getCampusById(String campusId) async {
    try {
      final doc =
          await _firestore.collection(_campusesCollection).doc(campusId).get();
      if (!doc.exists) return null;
      return Campus.fromJson(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Error fetching campus: $e');
      return null;
    }
  }

  /// Seed campuses into Firestore (run once for initial setup)
  Future<void> seedCampuses() async {
    try {
      final snapshot =
          await _firestore.collection(_campusesCollection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Campuses already seeded.');
        return;
      }

      final campuses = [
        {
          'name': 'NIAT – Chaitanya (Deemed to be University)',
          'city': 'Hyderabad',
          'isActive': true
        },
        {
          'name': 'NIAT – Aurora (Deemed to be University)',
          'city': 'Hyderabad',
          'isActive': true
        },
        {
          'name': "NIAT – St. Mary's University",
          'city': 'Hyderabad',
          'isActive': true
        },
        {
          'name': 'NIAT – S-VYASA University School of Advanced Studies',
          'city': 'Bangalore',
          'isActive': true
        },
        {
          'name': 'NIAT – Yenepoya University',
          'city': 'Mangalore',
          'isActive': true
        },
        {
          'name': 'NIAT – Takshashila University',
          'city': 'Ahmedabad',
          'isActive': true
        },
        {
          'name':
              'NIAT – B. S. Abdur Rahman Crescent Institute of Science & Technology',
          'city': 'Chennai',
          'isActive': true
        },
        {
          'name':
              'NIAT – AMET University (Academy of Maritime Education & Training)',
          'city': 'Chennai',
          'isActive': true
        },
        {
          'name': 'NIAT – Ajeenkya DY Patil University',
          'city': 'Pune',
          'isActive': true
        },
        {'name': 'NIAT – Alard University', 'city': 'Pune', 'isActive': true},
        {
          'name': 'NIAT – Sanjay Ghodawat University',
          'city': 'Kolhapur',
          'isActive': true
        },
        {
          'name': 'NIAT – Sharda University',
          'city': 'Greater Noida',
          'isActive': true
        },
        {
          'name': 'NIAT – Noida International University',
          'city': 'Noida',
          'isActive': true
        },
        {'name': 'NIAT – NRI University', 'city': 'Bhopal', 'isActive': true},
        {
          'name':
              'NIAT – Annamacharya University (Institute of Technology & Sciences)',
          'city': 'Rajampet',
          'isActive': true
        },
        {
          'name':
              'NIAT – Chalapathi Institute of Technology / Chalapathi Institute of Engineering & Technology',
          'city': 'Guntur',
          'isActive': true
        },
        {
          'name': 'NIAT – BEST Innovation University',
          'city': 'Gooty',
          'isActive': true
        },
        {
          'name':
              'NIAT – Nadimpalli Satyanarayana Raju Institute of Technology (NSRIT)',
          'city': 'Visakhapatnam',
          'isActive': true
        },
        {
          'name': 'NIAT – Scope Global Skills University',
          'city': 'Bhopal',
          'isActive': true
        },
        {
          'name': 'NIAT – Vivekananda Global University',
          'city': 'Jaipur',
          'isActive': true
        },
      ];

      final batch = _firestore.batch();
      for (final campus in campuses) {
        final docRef = _firestore.collection(_campusesCollection).doc();
        batch.set(docRef, campus);
      }
      await batch.commit();
      debugPrint('✅ Seeded ${campuses.length} NIAT campuses.');
    } catch (e) {
      debugPrint('Error seeding campuses: $e');
    }
  }

  /// Clear cache (useful after admin changes)
  void clearCache() {
    _cachedCampuses = null;
  }
}
