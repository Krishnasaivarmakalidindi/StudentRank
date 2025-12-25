import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studentrank/models/file_model.dart';
import 'package:studentrank/services/file_share_service.dart';

class FileShareProvider extends ChangeNotifier {
  final FileShareService _fileService = FileShareService();
  
  List<FileModel> _files = [];
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  StreamSubscription<List<FileModel>>? _filesSubscription;

  List<FileModel> get files => _files;
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;

  void initFiles(String groupId) {
    _isLoading = true;
    notifyListeners();

    _filesSubscription?.cancel();
    _filesSubscription = _fileService.getFiles(groupId).listen((files) {
      _files = files;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error loading files: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> uploadFile({
    required String groupId,
    required String userId,
    required String userName,
    required File file,
    required String description,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      await _fileService.uploadFile(
        groupId: groupId,
        userId: userId,
        userName: userName,
        file: file,
        description: description,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> deleteFile(String groupId, String fileId, String fileUrl) async {
    try {
      await _fileService.deleteFile(groupId, fileId, fileUrl);
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _filesSubscription?.cancel();
    super.dispose();
  }
}
