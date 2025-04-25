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
        'name': 'Sarah Johnson',
        'avatar': null,
        'title': 'Product Manager at TechCorp',
      },
      'timeAgo': '2h',
      'content': 'Excited to announce that we\'ve just launched our new AI-powered feature that helps teams collaborate better! #ProductManagement #AI #Innovation',
      'likes': 128,
      'comments': 32,
      'hasImage': true,
    },
    {
      'id': '2',
      'user': {
        'name': 'Alex Chen',
        'avatar': null,
        'title': 'Software Engineer',
      },
      'timeAgo': '5h',
      'content': 'Just finished a fascinating course on advanced machine learning algorithms. Looking forward to applying these concepts in my next project! Anyone here working on similar tech?',
      'likes': 95,
      'comments': 18,
      'hasImage': false,
    },
    {
      'id': '3',
      'user': {
        'name': 'Priya Patel',
        'avatar': null,
        'title': 'UX Researcher',
      },
      'timeAgo': '1d',
      'content': 'Here are my key takeaways from yesterday\'s UX conference:\n\n1. User research should start earlier in the product cycle\n2. Accessibility is not optional\n3. Qualitative data matters as much as quantitative\n\nWhat are your thoughts? #UXDesign #ProductDevelopment',
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
          'Peyvand',
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
                  index == 0 ? 'Your Story' : 'User ${String.fromCharCode(65 + index)}',
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