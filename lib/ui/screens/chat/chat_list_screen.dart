import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/config/routes.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'سارا جانسون',
      'avatar': null,
      'lastMessage': 'ممنون از اشتراک‌گذاری آن مقاله!',
      'time': '۲د',
      'unread': 2,
      'online': true,
    },
    {
      'id': '2',
      'name': 'علی چن',
      'avatar': null,
      'lastMessage': 'آیا برای یک تماس سریع فردا وقت دارید؟',
      'time': '۱س',
      'unread': 0,
      'online': false,
    },
    {
      'id': '3',
      'name': 'دستیار هوش مصنوعی پیوند',
      'avatar': null,
      'lastMessage':
      'من می‌توانم به شما در آمادگی برای مصاحبه کمک کنم. به من بگویید به چه چیزی نیاز دارید.',
      'time': '۳س',
      'unread': 1,
      'isAI': true,
      'online': true,
    },
    {
      'id': '4',
      'name': 'محمد رابرتز',
      'avatar': null,
      'lastMessage': 'مهلت پروژه تا جمعه آینده تمدید شده است.',
      'time': '۵س',
      'unread': 0,
      'online': false,
    },
    {
      'id': '5',
      'name': 'پریا پاتل',
      'avatar': null,
      'lastMessage': 'طرح پیشنهادی جدید را دیدید؟',
      'time': '۱روز',
      'unread': 0,
      'online': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیام‌ها',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppTheme.secondaryColor),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'جستجوی پیام‌ها',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.lightTextColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: [Tab(text: 'چت‌ها'), Tab(text: 'گروه‌ها')],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.chat, color: Colors.white),
        onPressed: () {},
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chats Tab
          _buildChatList(),

          // Groups Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 80, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text(
                  'هنوز گروهی وجود ندارد',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'یک گروه ایجاد کنید تا با چندین نفر همکاری کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.lightTextColor),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('ایجاد گروه'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: _chats.length + 1, // +1 for AI Assistant card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAiAssistantCard();
        }

        final chat = _chats[index - 1];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildAiAssistantCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFFFF9A3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: Colors.white, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دستیار هوش مصنوعی',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'هر سؤالی درباره شغل، شبکه‌سازی یا مهارت‌های خود بپرسید',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, Routes.aiChat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        if (chat['isAI'] == true) {
          Navigator.pushNamed(context, Routes.aiChat);
        } else {
          Navigator.pushNamed(
            context,
            Routes.chat,
            arguments: {'chatId': chat['id'], 'name': chat['name']},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                  chat['isAI'] == true
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  child:
                  chat['isAI'] == true
                      ? Icon(Icons.psychology, color: Colors.white)
                      : Text(
                    chat['name'].substring(0, 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (chat['online'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                            chat['unread'] > 0
                                ? AppTheme.secondaryColor
                                : AppTheme.lightTextColor,
                            fontWeight:
                            chat['unread'] > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (chat['unread'] > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}