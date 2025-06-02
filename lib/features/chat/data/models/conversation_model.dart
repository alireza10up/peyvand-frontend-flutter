import 'chat_user_model.dart';
import 'chat_message_model.dart';

class ConversationModel {
  final int id;
  final List<ChatUserModel> participants;
  ChatMessageModel? lastMessage;
  int unreadCount;
  final DateTime createdAt;
  DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final participantsList = (json['participants'] as List<dynamic>)
        .map((e) => ChatUserModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ConversationModel(
      id: json['id'] as int,
      participants: participantsList,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  ChatUserModel getOtherParticipant(String currentUserId) {
    return participants.firstWhere((p) => p.id != currentUserId, orElse: () => participants.first);
  }
}