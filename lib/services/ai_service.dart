import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/helpers/token_manager.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart' as profile_user_model;
import 'package:peyvand/features/ai_chat/data/models/ai_chat_message_dto.dart';
import 'api_service.dart';

class AiService {
  final ApiService _apiService = ApiService();
  final TokenManager _tokenManager = TokenManager();
  final String _baseUrl = ApiService().getBaseUrl();

  Future<String> enhancePostContent(String currentText, profile_user_model.User? currentUserProfile) async {
    if (currentText.isEmpty) return '';

    String customPrompt = "Improve the following post content for a university social media platform. Make it more engaging, clear, and professional. ";
    if (currentUserProfile != null) {
      customPrompt += "The author is ${currentUserProfile.displayName ?? currentUserProfile.email}. ";
      if (currentUserProfile.university != null && currentUserProfile.university!.isNotEmpty) {
        customPrompt += "They study at ${currentUserProfile.university}. ";
      }
      if (currentUserProfile.skills != null && currentUserProfile.skills!.isNotEmpty) {
        customPrompt += "Their skills include: ${currentUserProfile.skills!.join(', ')}. ";
      }
    }
    customPrompt += "The original post is:\n\"$currentText\"";


    final List<AiMessageDto> messages = [
      AiMessageDto(role: "user", content: "Please improve this text for a social media post: \"$currentText\"")
    ];

    final ChatCompletionDto completionDto = ChatCompletionDto(
      messages: messages,
      customPrompt: customPrompt,
    );

    try {
      final responseJson = await _sendToAiCompletion(completionDto);
      return responseJson['response'] as String? ?? currentText;
    } catch (e) {
      print("Error enhancing post with AI: $e");
      if (e is ApiException && e.messages.isNotEmpty) {
        throw ApiException(messages: e.messages);
      }
      throw ApiException(messages: ['خطا در بهبود متن با هوش مصنوعی.']);
    }
  }


  Future<Map<String, dynamic>> getAiChatCompletion(List<AiMessageDto> messages, profile_user_model.User? currentUserProfile) async {
    String customPrompt = "You are a helpful and friendly AI assistant for university students on a social platform called 'Peyvand'. ";
    if (currentUserProfile != null) {
      customPrompt += "The user you are talking to is ${currentUserProfile.displayName ?? currentUserProfile.email}. ";
      if (currentUserProfile.university != null && currentUserProfile.university!.isNotEmpty) {
        customPrompt += "They study at ${currentUserProfile.university}. ";
      }
      if (currentUserProfile.bio != null && currentUserProfile.bio!.isNotEmpty) {
        customPrompt += "Their bio is: \"${currentUserProfile.bio}\". ";
      }
      if (currentUserProfile.skills != null && currentUserProfile.skills!.isNotEmpty) {
        customPrompt += "Their skills include: ${currentUserProfile.skills!.join(', ')}. ";
      }
      if (currentUserProfile.studentCode != null && currentUserProfile.studentCode!.isNotEmpty) {
        customPrompt += "Their student code is: ${currentUserProfile.studentCode}. ";
      }
      customPrompt += "Today's date is ${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}.";
    }

    final ChatCompletionDto completionDto = ChatCompletionDto(
      messages: messages,
      customPrompt: customPrompt,
    );
    return _sendToAiCompletion(completionDto);
  }

  Future<Map<String, dynamic>> _sendToAiCompletion(ChatCompletionDto dto) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(messages: ['کاربر وارد نشده است.']);
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/ai/completion'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final responseBody = jsonDecode(response.body);
      List<String> errorMessages = ['خطای ناشناخته از سرور AI'];
      String? errorType = responseBody['error'] as String?;
      if (responseBody['message'] != null) {
        if (responseBody['message'] is List) {
          errorMessages = List<String>.from(responseBody['message'].map((m) => m.toString()));
        } else if (responseBody['message'] is String) {
          errorMessages = [responseBody['message'] as String];
        }
      }
      throw ApiException(
        errorType: errorType,
        messages: errorMessages,
        statusCode: response.statusCode,
      );
    }
  }
}