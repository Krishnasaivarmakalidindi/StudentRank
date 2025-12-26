import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late FirebaseAuth _auth;
  bool _isTyping = false; // Mock typing state

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      final user = _auth.currentUser;

      if (user == null) {
        _showError('User not authenticated. Please login first.');
        return;
      }

      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? user.displayName ?? 'Unknown User';
      final userAvatar = userDoc.data()?['avatar'] ?? user.photoURL ?? '';

      // Send message using ChatService
      await _chatService.sendMessage(
        groupId: widget.groupId,
        messageText: messageText,
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
        backgroundColor: Colors.red,
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
            // Messages list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessagesStream(widget.groupId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final messages = snapshot.data!.docs;
                  // Assuming Stream is ordered by timestamp descending (newest first)
                  // We want to display newest at bottom, so we use reverse: true in ListView
                  // and keep the order from Firestore if it is descending.
                  // Wait, usually Chat lists start at bottom.
                  // Firestore query in ChatService should be orderBy('timestamp', descending: true).
                  // So index 0 is newest.
                  // ListView reverse: true means index 0 is at bottom.
                  // So we pass the list as is.

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      final isCurrentUser = messageData['userId'] == _auth.currentUser?.uid;
                      
                      // Check if previous message (next in list) is from same user to group them
                      bool isFirstInSequence = true;
                      if (index < messages.length - 1) {
                         final prevData = messages[index + 1].data() as Map<String, dynamic>;
                         if (prevData['userId'] == messageData['userId']) {
                           isFirstInSequence = false;
                         }
                      }

                      return _buildMessageBubble(
                        messageData: messageData,
                        isCurrentUser: isCurrentUser,
                        showAvatar: !isCurrentUser && isFirstInSequence,
                      );
                    },
                  );
                },
              ),
            ),

            // Mock Typing Indicator (Static for now, but UI ready)
            // if (_isTyping) ... [
            //   Padding(
            //     padding: const EdgeInsets.only(left: 20, bottom: 8),
            //     child: Text('Someone is typing...', style: TextStyle(color: Colors.grey, fontSize: 12)),
            //   )
            // ],

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Often slightly lighter than bg
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      color: Colors.grey,
                      onPressed: () {}, // Mock Emoji
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Colors.grey,
                      onPressed: () {}, // Mock Attachment
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
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A90E2), // Primary Blue
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

  Widget _buildMessageBubble({
    required Map<String, dynamic> messageData,
    required bool isCurrentUser,
    required bool showAvatar,
  }) {
    final messageText = messageData['messageText'] ?? '';
    final userName = messageData['userName'] ?? 'Unknown';
    final userAvatar = messageData['userAvatar'];
    final timestamp = messageData['timestamp'] as Timestamp?;

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
                backgroundImage: userAvatar != null && userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null,
                backgroundColor: Colors.grey[700],
                child: userAvatar == null || userAvatar.isEmpty
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
                    ? const Color(0xFF4A90E2) 
                    : const Color(0xFF2D2D2D), // Dark Gray for others
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
                        _formatTime(timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent), // Read receipt
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
            'No messages yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start the conversation!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('h:mm a').format(timestamp.toDate());
  }
}
