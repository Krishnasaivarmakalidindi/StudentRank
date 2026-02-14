import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studentrank/models/file_model.dart';
import 'package:path/path.dart' as path;

class FileShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file
  Future<void> uploadFile({
    required String groupId,
    required String userId,
    required String userName,
    required File file,
    required String description,
    required Function(double) onProgress,
  }) async {
    final fileName = path.basename(file.path);
    final fileRef = _storage.ref().child(
        'groups/$groupId/files/${DateTime.now().millisecondsSinceEpoch}_$fileName');

    final uploadTask = fileRef.putFile(file);

    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      onProgress(progress);
    });

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final fileSize = snapshot.totalBytes;

    // Determine file type simply by extension for now
    String fileType = 'unknown';
    final ext = path.extension(fileName).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
      fileType = 'image';
    } else if (['.pdf'].contains(ext)) {
      fileType = 'pdf';
    } else if (['.doc', '.docx'].contains(ext)) {
      fileType = 'doc';
    } else if (['.xls', '.xlsx'].contains(ext)) {
      fileType = 'xls';
    } else if (['.txt'].contains(ext)) {
      fileType = 'text';
    }

    // Create FileModel
    final docRef =
        _firestore.collection('groups').doc(groupId).collection('files').doc();
    final fileModel = FileModel(
      fileId: docRef.id,
      groupId: groupId,
      userId: userId,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      fileUrl: downloadUrl,
      description: description,
      uploadedAt: DateTime.now(),
      uploaderName: userName,
    );

    await docRef.set(fileModel.toMap());
  }

  // Stream files
  Stream<List<FileModel>> getFiles(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FileModel.fromMap(doc.data())).toList();
    });
  }

  // Delete file
  Future<void> deleteFile(String groupId, String fileId, String fileUrl) async {
    // Delete from Storage
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      // Ignore if not found
    }

    // Delete from Firestore
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('files')
        .doc(fileId)
        .delete();
  }
}
