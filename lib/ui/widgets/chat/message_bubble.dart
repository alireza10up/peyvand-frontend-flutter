import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isAI;
  final String time;
  final String? status;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.isAI = false,
    required this.time,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppTheme.primaryColor
                  : isAI
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
                bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : isAI ? AppTheme.secondaryColor : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                  fontSize: 10,
                ),
              ),
              if (isMe && status != null) ...[
                SizedBox(width: 4),
                Icon(
                  status == 'sent'
                      ? Icons.check
                      : status == 'delivered'
                      ? Icons.done_all
                      : Icons.done_all,
                  size: 12,
                  color: status == 'read' ? Colors.blue : AppTheme.lightTextColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}