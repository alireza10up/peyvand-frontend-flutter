import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/ui/widgets/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _chatPartnerName = 'Sarah Johnson';
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hi there! How are you doing today?',
      'isMe': false,
      'time': '10:30 AM',
      'status': 'read',
    },
    {
      'id': '2',
      'text': 'I\'m doing great! Just finished a new feature for our app.',
      'isMe': true,
      'time': '10:32 AM',
      'status': 'read',
    },
    {
      'id': '3',
      'text': 'That\'s awesome! What feature did you implement?',
      'isMe': false,
      'time': '10:33 AM',
      'status': 'read',
    },
    {
      'id': '4',
      'text': 'I added an AI-powered recommendation system that suggests relevant connections based on user skills and interests.',
      'isMe': true,
      'time': '10:35 AM',
      'status': 'read',
    },
    {
      'id': '5',
      'text': 'Wow, that sounds impressive! Would love to see it in action sometime.',
      'isMe': false,
      'time': '10:36 AM',
      'status': 'read',
    },
    {
      'id': '6',
      'text': 'Thanks for sharing that article about machine learning applications in social networks. It was really insightful!',
      'isMe': false,
      'time': '11:20 AM',
      'status': 'read',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': _messageController.text,
      'isMe': true,
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      'status': 'sent',
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom after sending message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate reply after delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        final replyMessage = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': 'Thanks for your message! I\'ll look into this and get back to you soon.',
          'isMe': false,
          'time': '${DateTime.now().hour}:${DateTime.now().minute}',
          'status': 'sent',
        };

        setState(() {
          _isTyping = false;
          _messages.add(replyMessage);
        });

        // Scroll to bottom after receiving reply
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                _chatPartnerName.substring(0, 1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatPartnerName,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTyping ? 'typing...' : 'Online',
                  style: TextStyle(
                    color: _isTyping ? AppTheme.primaryColor : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: AppTheme.secondaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: AppTheme.secondaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.secondaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message['text'],
                  isMe: message['isMe'],
                  time: message['time'],
                  status: message['status'],
                );
              },
            ),
          ),
          if (_isTyping)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sarah is typing...',
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  color: AppTheme.lightTextColor,
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppTheme.lightTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined),
                        color: AppTheme.lightTextColor,
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}