import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studentrank/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send message to group
  Future<void> sendMessage({
    required String groupId,
    required String messageText,
    required String userName,
    required String userAvatar,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create message document
      // We use doc().set() instead of add() so we can include the ID in the document
      // which is helpful for the Message model mapping
      final messageRef = _firestore
          .collection('study_groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'messageId': messageRef.id, // Include ID for easier model mapping
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'messageText': messageText,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
      });

      // Update group's lastMessage and messageCount
      await _firestore.collection('study_groups').doc(groupId).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      }).catchError((error) {
        // print('Error updating group: $error');
        // Don't throw, message was saved
      });
    } catch (error) {
      // print('Error sending message: $error');
      rethrow; // Re-throw so UI can handle the error
    }
  }

  // Get messages stream for a group (Returning QuerySnapshot as requested)
  Stream<QuerySnapshot> getMessagesStream(String groupId) {
    try {
      return _firestore
          .collection('study_groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50) // Load last 50 messages
          .snapshots();
    } catch (error) {
      // print('Error getting messages: $error');
      rethrow;
    }
  }

  // Get message count
  Future<int> getMessageCount(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('study_groups')
          .doc(groupId)
          .collection('messages')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (error) {
      // print('Error getting message count: $error');
      return 0;
    }
  }

  // Compatibility method for ChatProvider
  Stream<List<Message>> getMessages(String groupId) {
    return getMessagesStream(groupId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure messageId is present (if we didn't save it, use doc.id)
        if (!data.containsKey('messageId')) {
          data['messageId'] = doc.id;
        }
        return Message.fromMap(data);
      }).toList();
    });
  }

  // Delete message
  Future<void> deleteMessage(String groupId, String messageId) async {
    await _firestore
        .collection('study_groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
