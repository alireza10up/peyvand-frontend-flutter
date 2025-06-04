import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:peyvand/config/app_assets.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/ai_chat/data/models/ai_chat_message_dto.dart';
import 'package:peyvand/services/api_service.dart';

class AiChatBubble extends StatelessWidget {
  final AiMessageDto message;
  final bool isUser;
  final bool showAvatar;
  final String? profileImageUrl;
  final String? userFirstName;

  const AiChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.showAvatar = true,
    this.profileImageUrl,
    this.userFirstName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isUser ? Colors.white : theme.colorScheme.onSurface;
    final apiService = ApiService();

    Widget avatarWidget = const SizedBox(width: 40);
    if (showAvatar) {
      if (isUser) {
        String? fullAvatarUrl;
        if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
          fullAvatarUrl = apiService.getBaseUrl() + profileImageUrl!;
        }
        avatarWidget = CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.accentColor.withOpacity(0.2),
          backgroundImage: fullAvatarUrl != null ? NetworkImage(fullAvatarUrl) : null,
          child: fullAvatarUrl == null
              ? Text(
            userFirstName?.substring(0, 1).toUpperCase() ?? "U",
            style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
          )
              : null,
        );
      } else {
        avatarWidget = CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          child: AppAssets.logoSmall(color: AppTheme.accentColor, backgroundColor: AppTheme.primaryColor.withOpacity(0.1)),
        );
      }
      avatarWidget = Padding(
        padding: EdgeInsets.only(right: isUser ? 0 : 8.0, left: isUser ? 8.0 : 0),
        child: avatarWidget,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) avatarWidget,
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                  color: isUser ? AppTheme.primaryColor : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ]
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: TextStyle(color: textColor, fontSize: 14.5, height: 1.45),
                  strong: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14.5,
                      height: 1.45
                  ),
                  em: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: textColor,
                      fontSize: 14.5,
                      height: 1.45
                  ),
                  code: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                    color: textColor,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                  ),
                  listBullet: TextStyle(color: textColor, fontSize: 14.5, height: 1.45),
                  horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 1.0, color: theme.dividerColor)
                      )
                  ),
                ),
              ),
            ),
          ),
          if (isUser) avatarWidget,
        ],
      ),
    );
  }
}