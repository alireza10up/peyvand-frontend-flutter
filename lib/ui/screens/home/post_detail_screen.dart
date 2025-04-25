import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/ui/widgets/post/ai_enhance_button.dart';

class PostDetailScreen extends StatefulWidget {
  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isBookmarked = false;

  final Map<String, dynamic> _post = {
    'id': '1',
    'user': {
      'name': 'Sarah Johnson',
      'avatar': null,
      'title': 'Product Manager at TechCorp',
    },
    'timeAgo': '2h',
    'content': 'Excited to announce that we\'ve just launched our new AI-powered feature that helps teams collaborate better! After months of hard work, our team has created a solution that uses machine learning to analyze team interactions and suggest improvements to workflows and communication patterns.\n\nThis feature can identify bottlenecks in project management, highlight successful collaboration patterns, and even recommend optimal team structures for specific types of projects.\n\n#ProductManagement #AI #Innovation #TeamCollaboration',
    'likes': 128,
    'comments': 32,
    'shares': 18,
    'hasImage': true,
  };

  final List<Map<String, dynamic>> _comments = [
    {
      'id': '1',
      'user': {
        'name': 'Alex Chen',
        'avatar': null,
      },
      'content': 'This is amazing! Would love to learn more about how the AI analyzes team interactions. Is it based on communication frequency or does it also consider the content of messages?',
      'timeAgo': '1h',
      'likes': 24,
    },
    {
      'id': '2',
      'user': {
        'name': 'Priya Patel',
        'avatar': null,
      },
      'content': 'Congratulations on the launch! We\'ve been looking for something like this for our remote teams.',
      'timeAgo': '45m',
      'likes': 15,
    },
    {
      'id': '3',
      'user': {
        'name': 'Michael Roberts',
        'avatar': null,
      },
      'content': 'Interesting approach! How does it handle privacy concerns with analyzing team communications?',
      'timeAgo': '30m',
      'likes': 8,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'id': DateTime.now().toString(),
        'user': {
          'name': 'John Doe',
          'avatar': null,
        },
        'content': _commentController.text,
        'timeAgo': 'Just now',
        'likes': 0,
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post',
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
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppTheme.primaryColor : AppTheme.secondaryColor,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.secondaryColor),
            onPressed: () {
              // Show post options
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildPostOptions(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostHeader(),
                  _buildPostContent(),
                  if (_post['hasImage']) _buildPostImage(),
                  _buildPostStats(),
                  _buildActionButtons(),
                  _buildDivider(),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _post['user']['name'].substring(0, 1),
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _post['user']['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_post['user']['title']} • ${_post['timeAgo']}',
                  style: TextStyle(
                    color: AppTheme.lightTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _post['content'],
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: double.infinity,
      height: 240,
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.thumb_up,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 4),
              Text(
                '${_post['likes']} likes',
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${_post['comments']} comments • ${_post['shares']} shares',
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: 'Like',
            color: _isLiked ? AppTheme.primaryColor : null,
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
                _post['likes'] = _isLiked ? _post['likes'] + 1 : _post['likes'] - 1;
              });
            },
          ),
          _buildActionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            onTap: () {
              // Focus on comment input
              FocusScope.of(context).requestFocus(FocusNode());
              _commentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _commentController.text.length),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              // Share post
            },
          ),
          AiEnhanceButton(
            onTap: () {
              _showAiEnhanceOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppTheme.lightTextColor,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 8,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Comments (${_comments.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return _buildCommentItem(comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: comment['user']['name'] == 'John Doe'
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            child: Text(
              comment['user']['name'].substring(0, 1),
              style: TextStyle(
                color: comment['user']['name'] == 'John Doe'
                    ? Colors.white
                    : AppTheme.secondaryColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['user']['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(comment['content']),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        comment['timeAgo'],
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Like',
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Reply',
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16),
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
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              'JD',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _addComment,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostOptions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildOptionItem(
            icon: Icons.bookmark_outline,
            title: _isBookmarked ? 'Remove from saved' : 'Save post',
            onTap: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.visibility_off_outlined,
            title: 'Hide post',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.person_outline,
            title: 'View profile',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.flag_outlined,
            title: 'Report post',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.secondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppTheme.secondaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAiEnhanceOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI Enhancement Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _aiOption(
              icon: Icons.summarize,
              title: 'Summarize Post',
              subtitle: 'Get a brief summary of this post',
              onTap: () {
                Navigator.pop(context);
                _showAiSummary();
              },
            ),
            _aiOption(
              icon: Icons.translate,
              title: 'Translate Post',
              subtitle: 'Convert to your preferred language',
              onTap: () {
                Navigator.pop(context);
                _showLanguageSelection();
              },
            ),
            _aiOption(
              icon: Icons.psychology,
              title: 'Ask AI about this post',
              subtitle: 'Get AI insights on this content',
              onTap: () {
                Navigator.pop(context);
                _showAiInsights();
              },
            ),
            _aiOption(
              icon: Icons.lightbulb_outline,
              title: 'Generate related content ideas',
              subtitle: 'AI suggestions for your own posts',
              onTap: () {
                Navigator.pop(context);
                _showContentIdeas();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }

  void _showAiSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.summarize, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('AI Summary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TechCorp has launched a new AI feature that:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Analyzes team interactions to improve collaboration'),
            Text('• Identifies bottlenecks in project management'),
            Text('• Highlights successful collaboration patterns'),
            Text('• Recommends optimal team structures'),
            SizedBox(height: 16),
            Text(
              'Key focus: AI-powered team optimization and workflow improvements.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Copy to clipboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Summary copied to clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('English (Original)'),
            _languageOption('Farsi (Persian)'),
            _languageOption('Arabic'),
            _languageOption('French'),
            _languageOption('German'),
            _languageOption('Spanish'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _languageOption(String language) {
    return ListTile(
      title: Text(language),
      onTap: () {
        Navigator.pop(context);
        // Show translation loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                SizedBox(width: 16),
                Text('Translating...'),
              ],
            ),
          ),
        );

        // Simulate translation delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
          _showTranslation(language);
        });
      },
    );
  }

  void _showTranslation(String language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.translate, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Translated to $language'),
          ],
        ),
        content: Text(
          language == 'Farsi (Persian)'
              ? 'خوشحالم که اعلام کنم ما ویژگی جدید مبتنی بر هوش مصنوعی را راه‌اندازی کرده‌ایم که به تیم‌ها کمک می‌کند بهتر همکاری کنند! پس از ماه‌ها کار سخت، تیم ما راه‌حلی ایجاد کرده است که از یادگیری ماشین برای تحلیل تعاملات تیم استفاده می‌کند و بهبودهایی را در جریان‌های کاری و الگوهای ارتباطی پیشنهاد می‌دهد.'
              : _post['content'],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAiInsights() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('AI Insights'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This post is about:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• A new product launch in the AI and team collaboration space'),
            Text('• Using machine learning for team optimization'),
            Text('• Workflow improvement through data analysis'),
            SizedBox(height: 16),
            Text(
              'Related topics you might be interested in:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Team productivity measurement'),
            Text('• AI ethics in workplace monitoring'),
            Text('• Machine learning for business optimization'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Ask a follow-up question
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Ask AI about this post'),
                  content: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: Text('Ask'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Ask Follow-up'),
          ),
        ],
      ),
    );
  }

  void _showContentIdeas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Content Ideas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on this post, you could create content about:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _contentIdeaItem(
              'How AI is transforming team collaboration in 2023',
              '78% match with your profile',
            ),
            SizedBox(height: 12),
            _contentIdeaItem(
              'The ethics of using AI to monitor team performance',
              '65% match with your profile',
            ),
            SizedBox(height: 12),
            _contentIdeaItem(
              'Case study: Implementing AI in project management',
              '82% match with your profile',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate a draft post
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Content idea saved to drafts'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Save Ideas'),
          ),
        ],
      ),
    );
  }

  Widget _contentIdeaItem(String title, String match) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            match,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}