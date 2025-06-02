import 'package:flutter/foundation.dart';
import 'package:peyvand/features/chat/data/models/conversation_model.dart';
import 'package:peyvand/features/chat/data/models/chat_message_model.dart';
import 'package:peyvand/features/chat/data/models/message_status_enum.dart';
import 'package:peyvand/features/chat/data/services/chat_http_service.dart';
import 'package:peyvand/features/chat/data/services/socket_service.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart'
as profile_user_model;
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:peyvand/services/api_service.dart';

import '../models/chat_user_model.dart' as chat_user_model;

class ChatProvider with ChangeNotifier {
  final ChatHttpService _chatHttpService = ChatHttpService();
  final SocketService _socketService = SocketService();
  final String _currentUserId;
  final profile_user_model.User _currentUserProfile;

  List<ConversationModel> _conversations = [];
  Map<int, List<ChatMessageModel>> _messagesByConversation = {};
  Map<int, bool> _isLoadingMessages = {};
  Map<int, bool> _hasMoreMessages = {};
  bool _isLoadingConversations = false;
  Map<int, TypingUserModel?> _typingUsersByConversation = {};

  int? _activeConversationId;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  Map<int, TypingUserModel?> get typingUsersByConversation =>
      _typingUsersByConversation;

  ChatProvider(this._currentUserId, this._currentUserProfile) {
    _initializeSocket();
  }

  profile_user_model.User get currentUserProfile => _currentUserProfile;

  void setActiveConversationId(int? conversationId) {
    _activeConversationId = conversationId;
    if (conversationId != null) {
      markMessagesAsRead(conversationId);
    }
  }
  int? getActiveConversationId() => _activeConversationId;


  Future<void> _initializeSocket() async {
    await _socketService.connect();
    _socketService.on('newMessage', _handleNewMessage);
    _socketService.on('messageStatusUpdated', _handleMessageStatusUpdate);
    _socketService.on('userTyping', _handleUserTyping);
    _socketService.on('userStoppedTyping', _handleUserStoppedTyping);
  }

  List<ChatMessageModel> getMessagesForConversation(int conversationId) {
    return _messagesByConversation[conversationId] ?? [];
  }

  bool isLoadingMessages(int conversationId) {
    return _isLoadingMessages[conversationId] ?? false;
  }

  void _handleNewMessage(dynamic data) {
    try {
      final messageFromServer =
      ChatMessageModel.fromJson(data as Map<String, dynamic>);
      final conversationId = messageFromServer.conversationId;

      if (!_messagesByConversation.containsKey(conversationId)) {
        _messagesByConversation[conversationId] = [];
      }
      final messageList = _messagesByConversation[conversationId]!;

      final existingMessageIndex = messageList
          .indexWhere((m) => m.id == messageFromServer.id && m.id != -1);

      if (existingMessageIndex != -1) {
        messageList[existingMessageIndex] = messageFromServer;
      } else {
        bool replacedOptimistic = false;
        if (messageFromServer.sender.id == _currentUserId) {
          final optimisticIndex = messageList.lastIndexWhere((m) =>
          m.id == -1 &&
              m.sender.id == _currentUserId &&
              (m.content == messageFromServer.content || (m.content == null && messageFromServer.content == null)) &&
              messageFromServer.createdAt.difference(m.createdAt).inSeconds < 15);
          if (optimisticIndex != -1) {
            messageList[optimisticIndex] = messageFromServer;
            replacedOptimistic = true;
          }
        }
        if (!replacedOptimistic) {
          messageList.add(messageFromServer);
        }
      }

      messageList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _updateConversationListWithMessage(messageFromServer, isNewUnreadMessage: messageFromServer.sender.id != _currentUserId);

      if (_activeConversationId == conversationId && messageFromServer.sender.id != _currentUserId) {
        markMessagesAsRead(conversationId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling new message from socket: $e');
    }
  }

  void _updateConversationListWithMessage(ChatMessageModel message, {bool isNewUnreadMessage = false}) {
    final index =
    _conversations.indexWhere((c) => c.id == message.conversationId);
    if (index != -1) {
      final conversation = _conversations[index];
      conversation.lastMessage = message;
      conversation.updatedAt = message.createdAt;

      if (isNewUnreadMessage && _activeConversationId != message.conversationId) {
        conversation.unreadCount = (conversation.unreadCount) + 1;
      } else if (message.sender.id == _currentUserId || _activeConversationId == message.conversationId) {
        conversation.unreadCount = 0;
      }
      _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else {
      fetchConversations();
    }
  }

  void _handleMessageStatusUpdate(dynamic data) {
    try {
      final conversationId = data['conversationId'] as int;
      final readerId = data['readerId'].toString();
      final statusString = data['status'] as String?;
      final status = MessageStatus.fromString(statusString);

      bool conversationListUpdated = false;
      bool messageListUpdated = false;

      if (_messagesByConversation.containsKey(conversationId)) {
        final List<ChatMessageModel> updatedMessages = [];
        for (var msg in _messagesByConversation[conversationId]!) {
          ChatMessageModel updatedMsg = msg;
          if (msg.sender.id == _currentUserId && readerId != _currentUserId && status == MessageStatus.READ && msg.status != MessageStatus.READ) {
            updatedMsg = msg.copyWith(status: MessageStatus.READ);
            messageListUpdated = true;
          }
          else if (msg.sender.id != _currentUserId && readerId == _currentUserId && status == MessageStatus.READ && msg.status != MessageStatus.READ) {
            updatedMsg = msg.copyWith(status: MessageStatus.READ);
            messageListUpdated = true;
          }
          updatedMessages.add(updatedMsg);
        }
        if(messageListUpdated) {
          _messagesByConversation[conversationId] = updatedMessages;
        }
      }

      final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final conversation = _conversations[convIndex];
        if (readerId == _currentUserId && status == MessageStatus.READ) {
          if (conversation.unreadCount > 0) {
            conversation.unreadCount = 0;
            conversationListUpdated = true;
          }
          if (conversation.lastMessage?.sender.id != _currentUserId && conversation.lastMessage?.status != MessageStatus.READ) {
            conversation.lastMessage = conversation.lastMessage?.copyWith(status: MessageStatus.READ);
            conversationListUpdated = true;
          }
        }
        else if (readerId != _currentUserId && status == MessageStatus.READ) {
          if (conversation.lastMessage?.sender.id == _currentUserId && conversation.lastMessage?.status != MessageStatus.READ) {
            conversation.lastMessage = conversation.lastMessage?.copyWith(status: MessageStatus.READ);
            conversationListUpdated = true;
          }
        }
      }

      if (messageListUpdated || conversationListUpdated) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error handling message status update: $e");
    }
  }


  void _handleUserTyping(dynamic data) {
    final conversationId = data['conversationId'] as int;
    final userId = data['userId'].toString();
    final userName = data['userName'] as String?;
    if (userId != _currentUserId) {
      _typingUsersByConversation[conversationId] =
          TypingUserModel(id: userId, name: userName ?? 'کاربر');
      notifyListeners();
    }
  }

  void _handleUserStoppedTyping(dynamic data) {
    final conversationId = data['conversationId'] as int;
    final userId = data['userId'].toString();
    if (userId != _currentUserId) {
      _typingUsersByConversation.remove(conversationId);
      notifyListeners();
    }
  }

  Future<void> fetchConversations({bool forceRefresh = false}) async {
    if (_isLoadingConversations && !forceRefresh) return;
    _isLoadingConversations = true;
    if (!forceRefresh) notifyListeners();

    try {
      _conversations =
      await _chatHttpService.getUserConversations(_currentUserId);
      _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      _conversations = [];
    }
    _isLoadingConversations = false;
    notifyListeners();
  }

  Future<void> fetchMessages(int conversationId,
      {bool loadMore = false}) async {
    if ((_isLoadingMessages[conversationId] ?? false) && !loadMore) return;

    _isLoadingMessages[conversationId] = true;
    if (!loadMore) {
      _messagesByConversation[conversationId] = [];
      _hasMoreMessages[conversationId] = true;
    }
    notifyListeners();

    try {
      final newMessages =
      await _chatHttpService.getMessagesForConversation(conversationId);
      if (!mounted) return;

      if (newMessages.isEmpty && loadMore) {
        _hasMoreMessages[conversationId] = false;
      }

      final currentMessages =
      List<ChatMessageModel>.from(_messagesByConversation[conversationId] ?? []);

      for (var newMessage in newMessages) {
        final existingIndex =
        currentMessages.indexWhere((m) => m.id == newMessage.id && m.id != -1);
        if (existingIndex == -1) {
          currentMessages.add(newMessage);
        } else {
          currentMessages[existingIndex] = newMessage;
        }
      }

      currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _messagesByConversation[conversationId] = currentMessages;

      if (!loadMore && newMessages.isNotEmpty) {
        await markMessagesAsRead(conversationId);
      }
    } catch (e) {
      debugPrint(
          'Error fetching messages for conversation $conversationId: $e');
    }
    _isLoadingMessages[conversationId] = false;
    notifyListeners();
  }

  Future<ChatMessageModel?> sendMessage({
    required int conversationId,
    String? content,
    List<int>? attachmentFileIds,
  }) async {
    if ((content == null || content.trim().isEmpty) &&
        (attachmentFileIds == null || attachmentFileIds.isEmpty)) {
      return null;
    }

    final tempId = const Uuid().v4();
    final optimisticMessage = ChatMessageModel(
      id: -1,
      tempId: tempId,
      content: content,
      sender:
      chat_user_model.ChatUserModel.fromProfileUser(_currentUserProfile),
      conversationId: conversationId,
      attachments: [],
      status: MessageStatus.SENT,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    if (!_messagesByConversation.containsKey(conversationId)) {
      _messagesByConversation[conversationId] = [];
    }

    _messagesByConversation[conversationId]!.add(optimisticMessage);
    _updateConversationListWithMessage(optimisticMessage, isNewUnreadMessage: false);
    notifyListeners();

    try {
      final sentMessageFromServer = await _chatHttpService.createMessage(
        conversationId: conversationId,
        content: content,
        attachmentFileIds: attachmentFileIds,
      );

      if (!mounted) return null;

      final index = _messagesByConversation[conversationId]
          ?.indexWhere((m) => m.tempId == tempId);
      if (index != null && index != -1) {
        _messagesByConversation[conversationId]![index] = sentMessageFromServer;
      } else {
        _messagesByConversation[conversationId]?.removeWhere((m) => m.id == -1 && m.content == content && m.sender.id == _currentUserId);
        final serverMsgIndex = _messagesByConversation[conversationId]?.indexWhere((m)=> m.id == sentMessageFromServer.id);
        if(serverMsgIndex == null || serverMsgIndex == -1){
          _messagesByConversation[conversationId]?.add(sentMessageFromServer);
        } else {
          _messagesByConversation[conversationId]![serverMsgIndex] = sentMessageFromServer;
        }
      }

      _messagesByConversation[conversationId]
          ?.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _updateConversationListWithMessage(sentMessageFromServer, isNewUnreadMessage: false);
      notifyListeners();
      return sentMessageFromServer;
    } catch (e) {
      debugPrint('Error sending message via HTTP: $e');
      if (!mounted) return null;
      final index = _messagesByConversation[conversationId]
          ?.indexWhere((m) => m.tempId == tempId);
      if (index != null && index != -1) {
        _messagesByConversation[conversationId]![index] =
            _messagesByConversation[conversationId]![index]
                .copyWith(status: MessageStatus.FAILED);
      }
      notifyListeners();
      return null;
    }
  }

  Future<List<int>> uploadChatImages(List<XFile> images) async {
    List<int> uploadedFileIds = [];
    final ApiService apiService = ApiService();

    for (var imageXFile in images) {
      File file = File(imageXFile.path);
      String? mimeType = lookupMimeType(file.path);

      if (mimeType == null || !mimeType.startsWith('image/')) {
        mimeType = imageXFile.mimeType;
        if (mimeType == null || !mimeType.startsWith('image/')) {
          mimeType = 'image/jpeg';
          debugPrint("Could not determine valid image MIME type for ${imageXFile.name}, falling back to $mimeType");
        }
      }
      debugPrint("Uploading ${imageXFile.name} with determined MIME type: $mimeType");

      try {
        final response = await apiService.uploadFile(
          '/files/public/upload',
          file,
          fieldName: 'file',
          mimeType: mimeType,
        );
        if (response['success'] == true && response['id'] != null) {
          uploadedFileIds.add(response['id'] as int);
        } else {
          debugPrint(
              'Failed to upload image: ${imageXFile.name} - Server error: ${response['message']}');
        }
      } catch (e) {
        debugPrint('Error uploading image ${imageXFile.name}: $e');
      }
    }
    return uploadedFileIds;
  }

  Future<ConversationModel?> createOrGetConversationWithUser(
      int participantId) async {
    if (participantId.toString() == _currentUserId) return null;
    _isLoadingConversations = true;
    notifyListeners();
    try {
      final conversation = await _chatHttpService.createOrGetConversation(
          participantId, _currentUserId);
      final existingConvIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (existingConvIndex == -1) {
        _conversations.insert(0, conversation);
      } else {
        _conversations[existingConvIndex] = conversation;
      }
      _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _isLoadingConversations = false;
      notifyListeners();
      return conversation;
    } catch (e) {
      _isLoadingConversations = false;
      notifyListeners();
      debugPrint("Error creating or getting conversation: $e");
      return null;
    }
  }

  void joinConversation(int conversationId) {
    _socketService.emit('joinConversation', {'conversationId': conversationId});
    setActiveConversationId(conversationId);
  }

  void leaveConversation(int conversationId) {
    _socketService.emit('leaveConversation', {'conversationId': conversationId});
    if (_activeConversationId == conversationId) {
      setActiveConversationId(null);
    }
    _typingUsersByConversation.remove(conversationId);
    notifyListeners();
  }

  void startTyping(int conversationId) {
    _socketService.emit('startTyping', {'conversationId': conversationId});
  }

  void stopTyping(int conversationId) {
    _socketService.emit('stopTyping', {'conversationId': conversationId});
  }

  Future<void> markMessagesAsRead(int conversationId) async {
    try {
      if (_activeConversationId != conversationId) return;

      await _chatHttpService.markMessagesAsRead(conversationId);

      bool changedInMessages = false;
      if (_messagesByConversation.containsKey(conversationId)) {
        final List<ChatMessageModel> updatedLocalMessages = [];
        for (var msg in _messagesByConversation[conversationId]!) {
          if (msg.sender.id != _currentUserId && msg.status != MessageStatus.READ) {
            updatedLocalMessages.add(msg.copyWith(status: MessageStatus.READ));
            changedInMessages = true;
          } else {
            updatedLocalMessages.add(msg);
          }
        }
        if (changedInMessages) {
          _messagesByConversation[conversationId] = updatedLocalMessages;
        }
      }

      final convIndex =
      _conversations.indexWhere((c) => c.id == conversationId);
      bool changedInConversationList = false;
      if (convIndex != -1) {
        if (_conversations[convIndex].unreadCount > 0) {
          _conversations[convIndex].unreadCount = 0;
          changedInConversationList = true;
        }
        if (_conversations[convIndex].lastMessage?.sender.id !=
            _currentUserId &&
            _conversations[convIndex].lastMessage?.status !=
                MessageStatus.READ) {
          _conversations[convIndex].lastMessage = _conversations[convIndex]
              .lastMessage
              ?.copyWith(status: MessageStatus.READ);
          changedInConversationList = true;
        }
      }

      if (changedInMessages || changedInConversationList) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint(
          "Error marking messages as read in provider for $conversationId: $e");
    }
  }

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, convo) => sum + convo.unreadCount);
  }

  bool get mounted => true;

  @override
  void dispose() {
    _socketService.off('newMessage', _handleNewMessage);
    _socketService.off('messageStatusUpdated', _handleMessageStatusUpdate);
    _socketService.off('userTyping', _handleUserTyping);
    _socketService.off('userStoppedTyping', _handleUserStoppedTyping);
    _socketService.disconnect();
    super.dispose();
  }
}

class TypingUserModel {
  final String id;
  final String name;
  TypingUserModel({required this.id, required this.name});
}