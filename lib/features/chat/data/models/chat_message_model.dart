import 'chat_user_model.dart';
import 'chat_attachment_model.dart';
import 'message_status_enum.dart';

class ChatMessageModel {
  final int id;
  final String? content;
  final ChatUserModel sender;
  final int conversationId;
  final List<ChatAttachmentModel>? attachments;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? tempId;

  ChatMessageModel({
    required this.id,
    this.content,
    required this.sender,
    required this.conversationId,
    this.attachments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.tempId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      content: json['content'] as String?,
      sender: ChatUserModel.fromJson(json['sender'] as Map<String, dynamic>),
      conversationId: json['conversationId'] as int,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => ChatAttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: MessageStatus.fromString(json['status'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  ChatMessageModel copyWith({
    int? id,
    String? content,
    ChatUserModel? sender,
    int? conversationId,
    List<ChatAttachmentModel>? attachments,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tempId,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      conversationId: conversationId ?? this.conversationId,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tempId: tempId ?? this.tempId,
    );
  }
}