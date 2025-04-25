import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/ui/widgets/chat/message_bubble.dart';
import 'package:peyvand/ui/widgets/chat/ai_suggestion_card.dart';

class AiChatScreen extends StatefulWidget {
  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello! I\'m your Peyvand AI Assistant. How can I help you today?',
      'isMe': false,
      'isAI': true,
      'time': '10:30 AM',
    },
  ];

  final List<String> _suggestions = [
    'Help me improve my resume',
    'Find networking opportunities',
    'Suggest skills I should learn',
    'How to prepare for a job interview',
    'Career advice for software engineers',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': messageText,
      'isMe': true,
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _isTyping = true;
    });

    // Scroll to bottom after sending message
    _scrollToBottom();

    // Simulate AI thinking and responding
    Future.delayed(Duration(seconds: 2), () {
      String response = '';

      if (messageText.toLowerCase().contains('resume')) {
        response = 'I can help you improve your resume! Here are some tips:\n\n1. Tailor your resume to each job application\n2. Quantify your achievements when possible\n3. Use action verbs\n4. Keep it concise and well-formatted\n5. Include relevant keywords\n\nWould you like me to review your resume if you share it?';
      } else if (messageText.toLowerCase().contains('interview')) {
        response = 'Preparing for interviews is crucial. Here\'s a quick guide:\n\n1. Research the company thoroughly\n2. Practice common questions\n3. Prepare examples of your past work\n4. Have questions ready to ask the interviewer\n5. Dress professionally and arrive early\n\nIs there a specific type of interview you\'re preparing for?';
      } else if (messageText.toLowerCase().contains('network') || messageText.toLowerCase().contains('networking')) {
        response = 'Networking is key to career growth! Try these strategies:\n\n1. Attend industry events and conferences\n2. Join professional groups on LinkedIn\n3. Reach out to alumni from your school\n4. Schedule informational interviews\n5. Follow up with new connections\n\nWould you like suggestions for networking events in your area?';
      } else if (messageText.toLowerCase().contains('skill')) {
        response = 'Based on current tech trends, these skills are in high demand:\n\n1. AI and Machine Learning\n2. Data Science\n3. Cloud Computing (AWS, Azure)\n4. Cybersecurity\n5. Full-stack Development\n6. UX/UI Design\n\nWhich of these areas interests you most?';
      } else {
        response = 'Thanks for your message! I\'m here to help with career advice, professional development, networking tips, and more. Feel free to ask me anything specific about your career goals or challenges.';
      }

      final aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': response,
        'isMe': false,
        'isAI': true,
        'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      };

      setState(() {
        _isTyping = false;
        _messages.add(aiResponse);
      });

      // Scroll to bottom after receiving reply
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
              child: Icon(
                Icons.psychology,
                size: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
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
            icon: Icon(Icons.refresh, color: AppTheme.secondaryColor),
            onPressed: () {
              // Reset conversation
              setState(() {
                _messages.clear();
                _messages.add({
                  'id': '1',
                  'text': 'Hello! I\'m your Peyvand AI Assistant. How can I help you today?',
                  'isMe': false,
                  'isAI': true,
                  'time': '${DateTime.now().hour}:${DateTime.now().minute}',
                });
              });
            },
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
              itemCount: _messages.length + (_messages.length == 1 ? 1 : 0), // Add suggestions only after first message
              itemBuilder: (context, index) {
                if (index == 1 && _messages.length == 1) {
                  // Show suggestions after the first AI message
                  return _buildSuggestions();
                }

                final adjustedIndex = _messages.length == 1 ? index : index;
                final message = _messages[adjustedIndex];

                return MessageBubble(
                  message: message['text'],
                  isMe: message['isMe'],
                  isAI: message['isAI'] ?? false,
                  time: message['time'],
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
                    'AI is thinking...',
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
                  icon: Icon(Icons.mic),
                  color: AppTheme.lightTextColor,
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask AI anything...',
                      hintStyle: TextStyle(color: AppTheme.lightTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(),
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

  Widget _buildSuggestions() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'You might want to ask:',
              style: TextStyle(
                color: AppTheme.lightTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return AiSuggestionCard(
                  suggestion: _suggestions[index],
                  onTap: () => _sendMessage(_suggestions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}