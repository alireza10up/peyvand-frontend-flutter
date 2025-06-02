import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/features/chat/data/models/conversation_model.dart';
import 'package:peyvand/features/chat/data/models/chat_message_model.dart';
import 'package:peyvand/errors/api_exception.dart';

class ChatHttpService {
  final ApiService _apiService = ApiService();

  Future<ConversationModel> createOrGetConversation(int participantId, String currentUserId) async {
    try {
      final response = await _apiService.post(
        '/chat/conversations',
        {'participantId': participantId},
      );
      return ConversationModel.fromJson(response, currentUserId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConversationModel>> getUserConversations(String currentUserId) async {
    try {
      final response = await _apiService.get('/chat/conversations');
      if (response is List) {
        return response
            .map((convJson) => ConversationModel.fromJson(convJson, currentUserId))
            .toList();
      }
      throw ApiException(messages: ['پاسخ سرور برای لیست گفتگوها نامعتبر است.']);
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatMessageModel> createMessage({
    required int conversationId,
    String? content,
    List<int>? attachmentFileIds,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'conversationId': conversationId,
      };
      if (content != null && content.isNotEmpty) {
        body['content'] = content;
      }
      if (attachmentFileIds != null && attachmentFileIds.isNotEmpty) {
        body['attachmentFileIds'] = attachmentFileIds;
      }
      final response = await _apiService.post('/chat/messages', body);
      return ChatMessageModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatMessageModel>> getMessagesForConversation(int conversationId) async {
    try {
      final response = await _apiService.get('/chat/conversations/$conversationId/messages');
      if (response is List) {
        return response
            .map((msgJson) => ChatMessageModel.fromJson(msgJson))
            .toList();
      }
      throw ApiException(messages: ['پاسخ سرور برای لیست پیام‌ها نامعتبر است.']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(int conversationId) async {
    try {
      await _apiService.post('/chat/conversations/$conversationId/messages/read', {});
    } catch (e) {
      rethrow;
    }
  }
}