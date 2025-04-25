import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/config/routes.dart';
import 'package:peyvand/ui/widgets/post/ai_enhance_button.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(context),
          if (post['hasImage']) _buildImage(),
          _buildActions(context),
          _buildStats(),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  post['user']['name'].substring(0, 1),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['user']['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${post['user']['title']} • ${post['timeAgo']}',
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        post['content'],
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      width: double.infinity,
      height: 200,
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

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _actionButton(Icons.thumb_up_outlined, 'پسندیدن'),
              SizedBox(width: 16),
              _actionButton(Icons.comment_outlined, 'نظر'),
              SizedBox(width: 16),
              _actionButton(Icons.share_outlined, 'اشتراک‌گذاری'),
            ],
          ),
          AiEnhanceButton(
            onTap: () {
              _showAiEnhanceOptions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.lightTextColor),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${post['likes']} پسند',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.lightTextColor,
            ),
          ),
          Text(
            '${post['comments']} نظر',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              'من',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'نظری اضافه کنید...',
                hintStyle: TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiEnhanceOptions(BuildContext context) {
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
              'گزینه‌های بهبود هوش مصنوعی',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _aiOption(
              context,
              Icons.auto_awesome,
              'بهبود این پست',
              'افزایش وضوح و جذابیت',
            ),
            _aiOption(
              context,
              Icons.summarize,
              'خلاصه‌سازی',
              'دریافت خلاصه‌ای کوتاه از این پست',
            ),
            _aiOption(
              context,
              Icons.translate,
              'ترجمه',
              'تبدیل به زبان مورد نظر شما',
            ),
            _aiOption(
              context,
              Icons.psychology,
              'از هوش مصنوعی درباره این بپرسید',
              'دریافت بینش هوش مصنوعی درباره این محتوا',
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiOption(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      ) {
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
      onTap: () {
        Navigator.pop(context);
        // Handle AI option
      },
    );
  }
}