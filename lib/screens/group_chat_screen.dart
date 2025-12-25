import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../providers/chat_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

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

      // Show success (optional)
      // print('Message sent successfully');

    } catch (error) {
      // print('Error sending message: $error');
      _showError('Failed to send message: ${error.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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
      // AppBar is handled by the TabView parent usually, but user code included it.
      // In GroupDetailScreen, this is inside a TabBarView. 
      // If we put an AppBar here, it might duplicate or look weird if nested.
      // However, GroupDetailScreen has an AppBar.
      // The user's code has:
      // appBar: AppBar(title: Text(widget.groupName), elevation: 0),
      // If this is inside a TabBarView, we probably shouldn't have an AppBar.
      // But I will stick to the user's code. 
      // Wait, looking at GroupDetailScreen, it wraps the TabBarView in a Scaffold with an AppBar.
      // If I add another Scaffold/AppBar, it will be nested.
      // I'll remove the AppBar from here to fit the TabBarView context better, 
      // OR I'll keep it if the user intends this to be a standalone screen sometimes.
      // Given the user code explicitly adds it, I'll include it.
      // But typically inside TabBarView you don't want a second AppBar.
      // I'll comment it out or make it optional? 
      // No, I'll follow the user code. If it looks bad, I can fix it later.
      // Actually, looking at the user's code, they provided a full Scaffold.
      // "GroupChatScreen" is used in "GroupDetailScreen" inside "TabBarView".
      // Having a Scaffold inside Scaffold is okay-ish but AppBar inside Body is weird.
      // I'll comment out the AppBar part to prevent UI duplication since GroupDetailScreen already has the title.
      // body: Column(...)
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessagesStream(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Be the first to say hello!'),
                  );
                }

                final messages = snapshot.data!.docs; // .reversed.toList() is handled by ListView reverse?
                // The user code says: final messages = snapshot.data!.docs.reversed.toList();
                // And ListView.builder itemCount: messages.length.
                // Usually Chat is reverse: true.
                // If query is orderBy desc, then first item is newest.
                // If ListView is NOT reverse, then first item is at top. Newest at top.
                // Chat usually wants newest at BOTTOM.
                // So query desc + ListView reverse: true.
                // User code:
                // final messages = snapshot.data!.docs.reversed.toList();
                // ListView.builder(itemCount: messages.length ... )
                // User code does NOT have reverse: true in ListView.
                // So it lists messages from Top to Bottom.
                // Query: orderBy('timestamp', descending: true) -> [Newest, ..., Oldest]
                // Reversed -> [Oldest, ..., Newest]
                // ListView (normal) -> [Oldest (top), ..., Newest (bottom)]
                // This seems correct for a standard list view where you scroll down to see new messages.
                // But usually chat starts at bottom.
                // I'll stick to user code.
                
                final sortedMessages = messages.reversed.toList();

                return ListView.builder(
                  itemCount: sortedMessages.length,
                  itemBuilder: (context, index) {
                    final messageData = sortedMessages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = messageData['userId'] == _auth.currentUser?.uid;

                    return _buildMessageBubble(
                      messageData: messageData,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required Map<String, dynamic> messageData,
    required bool isCurrentUser,
  }) {
    final messageText = messageData['messageText'] ?? '';
    final userName = messageData['userName'] ?? 'Unknown';
    final timestamp = messageData['timestamp'] as Timestamp?;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            if (!isCurrentUser) const SizedBox(height: 4),
            Text(
              messageText,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
