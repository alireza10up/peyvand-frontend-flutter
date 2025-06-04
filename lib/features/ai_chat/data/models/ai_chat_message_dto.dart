import 'package:flutter/foundation.dart';

class AiMessageDto {
  final String role;
  final String content;

  AiMessageDto({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory AiMessageDto.fromJson(Map<String, dynamic> json) {
    return AiMessageDto(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

class ChatCompletionDto {
  final List<AiMessageDto> messages;
  final String? customPrompt;

  ChatCompletionDto({
    required this.messages,
    this.customPrompt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'messages': messages.map((m) => m.toJson()).toList(),
    };
    if (customPrompt != null && customPrompt!.isNotEmpty) {
      data['customPrompt'] = customPrompt;
    }
    return data;
  }
}