import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studentrank/models/message.dart';
import 'package:studentrank/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<Message> _messages = [];
  bool _isLoading = false;
  StreamSubscription<List<Message>>? _messagesSubscription;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void initChat(String groupId) {
    _isLoading = true;
    notifyListeners(); 

    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessages(groupId).listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error loading messages: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String groupId,
    // userId is now handled by ChatService internal auth check
    required String userName,
    String? userAvatar,
    required String messageText,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      await _chatService.sendMessage(
        groupId: groupId,
        userName: userName,
        userAvatar: userAvatar ?? '',
        messageText: messageText,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
