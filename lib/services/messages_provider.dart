import 'package:flutter/material.dart';
import '../models/models.dart';

class MessagesProvider extends ChangeNotifier {
  final Map<String, List<MessageModel>> _conversations = {};
  final List<ConversationModel> _conversationList = [
    ConversationModel(
      id: 'conv1',
      user1Id: 'current_user',
      user2Id: 'sample_emp1',
      user2Name: 'Jean-Pierre Mbarga',
      lastMessage: 'Bonjour, je suis intéressé par vos services.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 2,
    ),
    ConversationModel(
      id: 'conv2',
      user1Id: 'current_user',
      user2Id: 'sample_emp2',
      user2Name: 'Amina Diallo',
      lastMessage: 'Merci pour votre message, je vous réponds dès que possible.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
  ];

  List<ConversationModel> get conversations => _conversationList;

  List<MessageModel> getMessages(String conversationId) {
    return _conversations[conversationId] ?? _getSampleMessages(conversationId);
  }

  List<MessageModel> _getSampleMessages(String conversationId) {
    if (conversationId == 'conv1') {
      return [
        MessageModel(
          senderId: 'sample_emp1',
          receiverId: 'current_user',
          content: 'Bonjour ! Comment puis-je vous aider ?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
        MessageModel(
          senderId: 'current_user',
          receiverId: 'sample_emp1',
          content: 'Bonjour, je suis intéressé par vos services.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
          isRead: true,
        ),
        MessageModel(
          senderId: 'sample_emp1',
          receiverId: 'current_user',
          content: 'Bien sûr ! Quel type de projet avez-vous en tête ?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];
    }
    return [];
  }

  void sendMessage(String conversationId, String senderId, String receiverId, String content) {
    final message = MessageModel(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = _getSampleMessages(conversationId);
    }
    _conversations[conversationId]!.add(message);

    final convIdx = _conversationList.indexWhere((c) => c.id == conversationId);
    if (convIdx >= 0) {
      final oldConv = _conversationList[convIdx];
      _conversationList[convIdx] = ConversationModel(
        id: oldConv.id,
        user1Id: oldConv.user1Id,
        user2Id: oldConv.user2Id,
        user2Name: oldConv.user2Name,
        user2Image: oldConv.user2Image,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );
      
      // Move active conversation to top
      final conv = _conversationList.removeAt(convIdx);
      _conversationList.insert(0, conv);
    }

    notifyListeners();
  }

  void startConversation(UserModel otherUser, String currentUserId) {
    final existingIdx = _conversationList.indexWhere(
      (c) => c.user2Id == otherUser.id,
    );

    if (existingIdx == -1) {
      _conversationList.insert(0, ConversationModel(
        user1Id: currentUserId,
        user2Id: otherUser.id,
        user2Name: otherUser.name,
        user2Image: otherUser.profileImagePath,
        lastMessage: 'Nouvelle conversation',
        unreadCount: 0,
      ));
    } else {
      // Bring existing to top
      final conv = _conversationList.removeAt(existingIdx);
      _conversationList.insert(0, conv);
    }
    notifyListeners();
  }
}
