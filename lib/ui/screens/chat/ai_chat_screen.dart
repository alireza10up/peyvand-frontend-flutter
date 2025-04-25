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
      'text': 'سلام! من دستیار هوش مصنوعی پیوند هستم. چطور می‌توانم امروز به شما کمک کنم؟',
      'isMe': false,
      'isAI': true,
      'time': '10:30',
    },
  ];

  final List<String> _suggestions = [
    'کمک برای بهبود رزومه من',
    'یافتن فرصت‌های شبکه‌سازی',
    'پیشنهاد مهارت‌هایی که باید یاد بگیرم',
    'چگونه برای مصاحبه شغلی آماده شوم',
    'مشاوره شغلی برای مهندسان نرم‌افزار',
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

      if (messageText.toLowerCase().contains('resume') || messageText.contains('رزومه')) {
        response = 'من می‌توانم به شما در بهبود رزومه‌تان کمک کنم! اینجا چند نکته است:\n\n۱. رزومه خود را برای هر درخواست شغلی سفارشی کنید\n۲. دستاوردهای خود را در صورت امکان به صورت کمّی بیان کنید\n۳. از افعال عملی استفاده کنید\n۴. آن را مختصر و با فرمت مناسب نگه دارید\n۵. کلمات کلیدی مرتبط را بگنجانید\n\nآیا می‌خواهید اگر رزومه خود را به اشتراک بگذارید، آن را بررسی کنم؟';
      } else if (messageText.toLowerCase().contains('interview') || messageText.contains('مصاحبه')) {
        response = 'آمادگی برای مصاحبه‌ها بسیار مهم است. اینجا یک راهنمای سریع است:\n\n۱. شرکت را به طور کامل بررسی کنید\n۲. سؤالات متداول را تمرین کنید\n۳. نمونه‌هایی از کارهای قبلی خود آماده کنید\n۴. سؤالاتی برای پرسیدن از مصاحبه‌کننده آماده کنید\n۵. لباس حرفه‌ای بپوشید و زودتر برسید\n\nآیا برای نوع خاصی از مصاحبه آماده می‌شوید؟';
      } else if (messageText.toLowerCase().contains('network') || messageText.toLowerCase().contains('networking') || messageText.contains('شبکه')) {
        response = 'شبکه‌سازی کلید رشد شغلی است! این استراتژی‌ها را امتحان کنید:\n\n۱. در رویدادها و کنفرانس‌های صنعتی شرکت کنید\n۲. به گروه‌های حرفه‌ای در لینکدین بپیوندید\n۳. با فارغ‌التحصیلان دانشگاه خود تماس بگیرید\n۴. مصاحبه‌های اطلاعاتی برنامه‌ریزی کنید\n۵. با ارتباطات جدید پیگیری کنید\n\nآیا می‌خواهید پیشنهاداتی برای رویدادهای شبکه‌سازی در منطقه خود دریافت کنید؟';
      } else if (messageText.toLowerCase().contains('skill') || messageText.contains('مهارت')) {
        response = 'بر اساس روندهای فعلی فناوری، این مهارت‌ها بسیار مورد تقاضا هستند:\n\n۱. هوش مصنوعی و یادگیری ماشین\n۲. علم داده\n۳. رایانش ابری (AWS، Azure)\n۴. امنیت سایبری\n۵. توسعه Full-stack\n۶. طراحی UX/UI\n\nکدام یک از این حوزه‌ها برای شما جذاب‌تر است؟';
      } else {
        response = 'ممنون از پیام شما! من اینجا هستم تا در مورد مشاوره شغلی، توسعه حرفه‌ای، نکات شبکه‌سازی و موارد دیگر به شما کمک کنم. لطفاً هر سؤال خاصی درباره اهداف یا چالش‌های شغلی خود دارید، بپرسید.';
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
                  'دستیار هوش مصنوعی',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isTyping ? 'در حال تایپ...' : 'آنلاین',
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
                  'text': 'سلام! من دستیار هوش مصنوعی پیوند هستم. چطور می‌توانم امروز به شما کمک کنم؟',
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
                    'هوش مصنوعی در حال فکر کردن است...',
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
                      hintText: 'هر سوالی از هوش مصنوعی بپرسید...',
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
              'شاید بخواهید بپرسید:',
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