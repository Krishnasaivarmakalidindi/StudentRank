import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/chat_service.dart';

// Constants for maintainability
class _AppColors {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color myMessageBg = Color(0xFF4A90E2);
  static const Color otherMessageBg = Color(0xFF2D2D2D);
  static const Color errorRed = Colors.red;
}

class _AppStrings {
  static const String usersCollection = 'users';
  static const String avatarField = 'avatar';
  static const String nameField = 'name';
  static const String unknownUser = 'Unknown User';
  static const String typeMessageHint = 'Type a message...';
  // ignore: unused_field
  static const String noMessages = 'No messages yet';
  // ignore: unused_field
  static const String startConversation = 'Start the conversation!';
}

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late FirebaseAuth _auth;
  
  // Optimization: Cache user data to avoid redundant reads
  String? _cachedUserName;
  String? _cachedUserAvatar;

  // Cleanup: Static date format for performance
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _fetchUserData();
  }
  
  // Optimization: Fetch user data once
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(_AppStrings.usersCollection)
            .doc(user.uid)
            .get();
        if (mounted) {
           setState(() {
             _cachedUserName = doc.data()?[_AppStrings.nameField] ?? user.displayName ?? _AppStrings.unknownUser;
             _cachedUserAvatar = doc.data()?[_AppStrings.avatarField] ?? user.photoURL ?? '';
           });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError('User not authenticated. Please login first.');
        return;
      }

      // Use cached data or fallback to defaults (Optimized)
      final userName = _cachedUserName ?? user.displayName ?? _AppStrings.unknownUser;
      final userAvatar = _cachedUserAvatar ?? user.photoURL ?? '';

      await _chatService.sendMessage(
        groupId: widget.groupId,
        messageText: text,
        userName: userName,
        userAvatar: userAvatar,
      );
    } catch (error) {
      _showError('Failed to send message: ${error.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessagesStream(widget.groupId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      final currentUid = _auth.currentUser?.uid;
                      final isCurrentUser = messageData['userId'] == currentUid;
                      
                      // Logic: Show avatar only on the last message of a user's sequence (bottom-most).
                      // Since list is reversed (0 is bottom), we check if the newer message (index-1) is from same user.
                      bool showAvatar = true;
                      if (index > 0) {
                          final newerMsgData = messages[index - 1].data() as Map<String, dynamic>;
                          if (newerMsgData['userId'] == messageData['userId']) {
                              showAvatar = false;
                          }
                      }

                      return MessageBubble(
                        messageText: messageData['messageText'] ?? '',
                        userName: messageData['userName'] ?? _AppStrings.unknownUser,
                        userAvatar: messageData['userAvatar'],
                        timestamp: messageData['timestamp'] as Timestamp?,
                        isCurrentUser: isCurrentUser,
                        showAvatar: showAvatar,
                        timeFormat: _timeFormat,
                      );
                    },
                  );
                },
              ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      color: Colors.grey,
                      onPressed: () {}, // TODO: Implement Emoji Picker
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Colors.grey,
                      onPressed: () {}, // TODO: Implement Attachment
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: _AppStrings.typeMessageHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: _AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            _AppStrings.noMessages,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            _AppStrings.startConversation,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Extracted Widget: MessageBubble
class MessageBubble extends StatelessWidget {
  final String messageText;
  final String userName;
  final String? userAvatar;
  final Timestamp? timestamp;
  final bool isCurrentUser;
  final bool showAvatar;
  final DateFormat timeFormat;

  const MessageBubble({
    super.key,
    required this.messageText,
    required this.userName,
    this.userAvatar,
    this.timestamp,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Safety: ensure no nulls in build
    final avatarUrl = userAvatar;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[700],
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                    ? CachedNetworkImageProvider(avatarUrl) 
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white))
                    : null,
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? _AppColors.myMessageBg 
                    : _AppColors.otherMessageBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isCurrentUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCurrentUser && showAvatar) ...[
                     Text(
                       userName,
                       style: TextStyle(
                         color: Colors.primaries[userName.hashCode % Colors.primaries.length],
                         fontWeight: FontWeight.bold,
                         fontSize: 12,
                       ),
                     ),
                     const SizedBox(height: 4),
                  ],
                  Text(
                    messageText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timestamp != null ? timeFormat.format(timestamp!.toDate()) : '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
