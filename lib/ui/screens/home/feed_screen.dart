import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/config/routes.dart';
import 'package:peyvand/ui/widgets/post/post_card.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': {
        'name': 'سارا جانسون',
        'avatar': null,
        'title': 'مدیر محصول در شرکت تک‌کورپ',
      },
      'timeAgo': '۲ ساعت',
      'content': 'خوشحالم که اعلام کنم ما به تازگی قابلیت جدید مبتنی بر هوش مصنوعی را راه‌اندازی کرده‌ایم که به تیم‌ها کمک می‌کند بهتر همکاری کنند! #مدیریت_محصول #هوش_مصنوعی #نوآوری',
      'likes': 128,
      'comments': 32,
      'hasImage': true,
    },
    {
      'id': '2',
      'user': {
        'name': 'علی چن',
        'avatar': null,
        'title': 'مهندس نرم‌افزار',
      },
      'timeAgo': '۵ ساعت',
      'content': 'به تازگی یک دوره جذاب درباره الگوریتم‌های پیشرفته یادگیری ماشین را تمام کردم. مشتاقم این مفاهیم را در پروژه بعدی خود به کار بگیرم! آیا کسی اینجا روی فناوری مشابهی کار می‌کند؟',
      'likes': 95,
      'comments': 18,
      'hasImage': false,
    },
    {
      'id': '3',
      'user': {
        'name': 'پریا پاتل',
        'avatar': null,
        'title': 'محقق تجربه کاربری',
      },
      'timeAgo': '۱ روز',
      'content': 'نکات کلیدی من از کنفرانس تجربه کاربری دیروز:\n\n۱. تحقیق کاربر باید زودتر در چرخه محصول آغاز شود\n۲. دسترس‌پذیری اختیاری نیست\n۳. داده‌های کیفی به اندازه داده‌های کمی اهمیت دارند\n\nنظر شما چیست؟ #طراحی_تجربه_کاربری #توسعه_محصول',
      'likes': 215,
      'comments': 47,
      'hasImage': true,
    },
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'پیوند',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.secondaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppTheme.secondaryColor),
            onPressed: () {
              Navigator.pushNamed(context, Routes.notifications);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });

          // Simulate refresh
          await Future.delayed(Duration(seconds: 1));

          setState(() {
            _isLoading = false;
          });
        },
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: _posts.length + 1, // +1 for the stories section
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildStoriesSection();
            }

            final post = _posts[index - 1];
            return PostCard(post: post);
          },
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 100,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            width: 70,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: index == 0
                          ? [Colors.grey.shade300, Colors.grey.shade300]
                          : [AppTheme.primaryColor, Colors.orange.shade300],
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: index == 0
                        ? Icon(Icons.add, color: AppTheme.primaryColor)
                        : Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  index == 0 ? 'استوری شما' : 'کاربر ${String.fromCharCode(65 + index)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}