import 'package:flutter/material.dart';
import 'package:peyvand/features/chat/data/models/chat_message_model.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/features/chat/data/models/message_status_enum.dart';
import 'package:peyvand/services/api_service.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  String _formatTime(DateTime dateTime) {
    return intl.DateFormat.Hm('fa_IR').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSentFailed = message.status == MessageStatus.FAILED;
    final ApiService apiService = ApiService();

    Widget mediaWidget = const SizedBox.shrink();
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      final attachment = message.attachments!.firstWhere(
              (att) => att.mimetype.startsWith('image/'),
          orElse: () => message.attachments!.first
      );

      if (attachment.mimetype.startsWith('image/')) {
        final imageUrl = apiService.getBaseUrl() + attachment.url;
        mediaWidget = Padding(
          padding: EdgeInsets.only(top: message.content != null && message.content!.isNotEmpty ? 8.0 : 0.0, bottom: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 100,
                    width: 100,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.0,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 40),
                  );
                },
              ),
            ),
          ),
        );
      }
      // TODO: Handle other attachment types (e.g., files, videos)
    }


    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
            color: isSentFailed
                ? Colors.red.shade100
                : (isMe
                ? AppTheme.primaryColor
                : theme.colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
              isMe ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight:
              isMe ? const Radius.circular(4) : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1))
            ]),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            mediaWidget,
            if (message.content != null && message.content!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: (message.attachments != null && message.attachments!.isNotEmpty) ? 4.0 : 0.0, bottom: 4.0),
                child: Text(
                  message.content!,
                  style: TextStyle(
                      color: isSentFailed
                          ? Colors.red.shade900
                          : (isMe ? Colors.white : theme.colorScheme.onSurface),
                      fontSize: 14.5,
                      height: 1.4),
                ),
              ),
            // SizedBox(height: mediaWidget != const SizedBox.shrink() || (message.content != null && message.content!.isNotEmpty) ? 3 : 0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: isSentFailed
                        ? Colors.red.shade700
                        : (isMe
                        ? Colors.white.withOpacity(0.8)
                        : theme.colorScheme.onSurfaceVariant
                        .withOpacity(0.7)),
                  ),
                ),
                if (isMe && message.id != -1) ...[
                  const SizedBox(width: 5),
                  Icon(
                    message.status == MessageStatus.READ
                        ? Icons.done_all_rounded
                        : (message.status == MessageStatus.SENT ||
                        message.status == MessageStatus.DELIVERED)
                        ? Icons.check_rounded
                        : Icons.schedule_rounded,
                    size: 15,
                    color: message.status == MessageStatus.READ
                        ? AppTheme.accentColor.withOpacity(isMe ? 1.0 : 0.8)
                        : (isMe
                        ? Colors.white.withOpacity(0.8)
                        : theme.colorScheme.onSurfaceVariant
                        .withOpacity(0.7)),
                  ),
                ],
                if (isSentFailed) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.error_outline_rounded,
                      size: 14, color: Colors.red.shade700),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}