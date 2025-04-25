import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'connection',
      'user': {
        'name': 'علی چن',
        'avatar': null,
      },
      'content': 'درخواست ارتباط شما را پذیرفت',
      'timeAgo': '۲ دقیقه',
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'like',
      'user': {
        'name': 'سارا جانسون',
        'avatar': null,
      },
      'content': 'پست شما درباره ادغام هوش مصنوعی را پسندید',
      'timeAgo': '۱ ساعت',
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'comment',
      'user': {
        'name': 'محمد رابرتز',
        'avatar': null,
      },
      'content': 'روی پست شما نظر داد: "بینش‌های عالی! دوست دارم بیشتر درباره نحوه پیاده‌سازی این موضوع بشنوم."',
      'timeAgo': '۳ ساعت',
      'isRead': true,
    },
    {
      'id': '4',
      'type': 'mention',
      'user': {
        'name': 'پریا پاتل',
        'avatar': null,
      },
      'content': 'شما را در یک نظر منشن کرد',
      'timeAgo': '۵ ساعت',
      'isRead': true,
    },
    {
      'id': '5',
      'type': 'job',
      'user': {
        'name': 'شرکت نوآوری‌های فناوری',
        'avatar': null,
      },
      'content': 'شغلی که با مهارت‌های شما مطابقت دارد منتشر کرد: "توسعه‌دهنده ارشد فلاتر"',
      'timeAgo': '۱ روز',
      'isRead': true,
    },
    {
      'id': '6',
      'type': 'ai',
      'content': 'دستیار هوش مصنوعی بر اساس فعالیت‌های اخیر شما پیشنهاداتی دارد',
      'timeAgo': '۱ روز',
      'isRead': true,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اعلان‌ها',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.lightTextColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: 'همه'),
            Tab(text: 'خوانده نشده'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: AppTheme.secondaryColor),
            onPressed: () {
              // Mark all as read
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All notifications
          _buildNotificationsList(_notifications),

          // Unread notifications
          _buildNotificationsList(_notifications.where((n) => n['isRead'] == false).toList()),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'اعلانی وجود ندارد',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData iconData;
    Color iconColor;

    switch (notification['type']) {
      case 'connection':
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'like':
        iconData = Icons.thumb_up;
        iconColor = Colors.pink;
        break;
      case 'comment':
        iconData = Icons.comment;
        iconColor = Colors.green;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.purple;
        break;
      case 'job':
        iconData = Icons.work;
        iconColor = Colors.brown;
        break;
      case 'ai':
        iconData = Icons.psychology;
        iconColor = AppTheme.primaryColor;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      color: notification['isRead'] ? null : AppTheme.primaryColor.withOpacity(0.05),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: notification['type'] == 'ai'
            ? CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        )
            : CircleAvatar(
          backgroundColor: notification['isRead'] ? Colors.grey.shade300 : AppTheme.primaryColor,
          child: Text(
            notification['user']['name'].substring(0, 1),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            children: [
              if (notification['type'] != 'ai')
                TextSpan(
                  text: notification['user']['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (notification['type'] != 'ai')
                TextSpan(text: ' '),
              TextSpan(text: notification['content']),
            ],
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                iconData,
                size: 14,
                color: iconColor,
              ),
              SizedBox(width: 4),
              Text(
                notification['timeAgo'],
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: AppTheme.lightTextColor,
          ),
          onPressed: () {},
        ),
        onTap: () {
          // Mark as read when tapped
          setState(() {
            notification['isRead'] = true;
          });

          // Navigate or show details
        },
      ),
    );
  }
}