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
      'name': 'سارا جانسون',
      'avatar': null,
      'title': 'مدیر محصول در تک‌کورپ',
    },
    'timeAgo': '۲ ساعت',
    'content': 'خوشحالم که اعلام کنم ما به تازگی قابلیت جدید مبتنی بر هوش مصنوعی را راه‌اندازی کرده‌ایم که به تیم‌ها کمک می‌کند بهتر همکاری کنند! پس از ماه‌ها تلاش سخت، تیم ما راه‌حلی ایجاد کرده است که از یادگیری ماشین برای تحلیل تعاملات تیم استفاده می‌کند و بهبودهایی در جریان‌های کاری و الگوهای ارتباطی پیشنهاد می‌دهد.\n\nاین قابلیت می‌تواند گلوگاه‌ها در مدیریت پروژه را شناسایی کند، الگوهای همکاری موفق را برجسته کند و حتی ساختارهای بهینه تیم را برای انواع خاصی از پروژه‌ها پیشنهاد دهد.\n\n#مدیریت_محصول #هوش_مصنوعی #نوآوری #همکاری_تیمی',
    'likes': 128,
    'comments': 32,
    'shares': 18,
    'hasImage': true,
  };

  final List<Map<String, dynamic>> _comments = [
    {
      'id': '1',
      'user': {
        'name': 'علی چن',
        'avatar': null,
      },
      'content': 'این فوق‌العاده است! دوست دارم بیشتر درباره نحوه تحلیل تعاملات تیم توسط هوش مصنوعی بدانم. آیا بر اساس تناوب ارتباطات است یا محتوای پیام‌ها را نیز در نظر می‌گیرد؟',
      'timeAgo': '۱ ساعت',
      'likes': 24,
    },
    {
      'id': '2',
      'user': {
        'name': 'پریا پاتل',
        'avatar': null,
      },
      'content': 'تبریک برای راه‌اندازی! ما به دنبال چیزی مشابه این برای تیم‌های دورکار خود بوده‌ایم.',
      'timeAgo': '۴۵ دقیقه',
      'likes': 15,
    },
    {
      'id': '3',
      'user': {
        'name': 'محمد رابرتز',
        'avatar': null,
      },
      'content': 'رویکرد جالبی است! چگونه نگرانی‌های مربوط به حریم خصوصی در تحلیل ارتباطات تیم را مدیریت می‌کنید؟',
      'timeAgo': '۳۰ دقیقه',
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
          'name': 'جان دو',
          'avatar': null,
        },
        'content': _commentController.text,
        'timeAgo': 'همین الان',
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
          'پست',
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
                '${_post['likes']} پسند',
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${_post['comments']} نظر • ${_post['shares']} اشتراک‌گذاری',
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
            label: '',
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
            label: '',
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
            onTap: () {
              // Share post
            }, label: '',
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
            'نظرات (${_comments.length})',
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
            backgroundColor: comment['user']['name'] == 'جان دو'
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
            child: Text(
              comment['user']['name'].substring(0, 1),
              style: TextStyle(
                color: comment['user']['name'] == 'جان دو'
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
                        '',
                        style: TextStyle(
                          color: AppTheme.lightTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        '',
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
                hintText: 'نظری بنویسید...',
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
            title: _isBookmarked ? 'حذف از ذخیره‌شده‌ها' : 'ذخیره پست',
            onTap: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.visibility_off_outlined,
            title: 'پنهان کردن پست',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.person_outline,
            title: 'مشاهده پروفایل',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildOptionItem(
            icon: Icons.flag_outlined,
            title: 'گزارش پست',
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
              'گزینه‌های بهبود هوش مصنوعی',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _aiOption(
              icon: Icons.summarize,
              title: 'خلاصه پست',
              subtitle: 'خلاصه‌ای کوتاه از این پست دریافت کنید',
              onTap: () {
                Navigator.pop(context);
                _showAiSummary();
              },
            ),
            _aiOption(
              icon: Icons.translate,
              title: 'ترجمه پست',
              subtitle: 'به زبان مورد نظر شما تبدیل کنید',
              onTap: () {
                Navigator.pop(context);
                _showLanguageSelection();
              },
            ),
            _aiOption(
              icon: Icons.psychology,
              title: 'از هوش مصنوعی درباره این پست بپرسید',
              subtitle: 'بینش هوش مصنوعی درباره این محتوا را دریافت کنید',
              onTap: () {
                Navigator.pop(context);
                _showAiInsights();
              },
            ),
            _aiOption(
              icon: Icons.lightbulb_outline,
              title: 'تولید ایده‌های محتوای مرتبط',
              subtitle: 'پیشنهادهای هوش مصنوعی برای پست‌های خودتان',
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
            Text('خلاصه هوش مصنوعی'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تک‌کورپ یک قابلیت جدید هوش مصنوعی راه‌اندازی کرده است که:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• تعاملات تیم را برای بهبود همکاری تحلیل می‌کند'),
            Text('• گلوگاه‌ها در مدیریت پروژه را شناسایی می‌کند'),
            Text('• الگوهای همکاری موفق را برجسته می‌کند'),
            Text('• ساختارهای بهینه تیم را پیشنهاد می‌دهد'),
            SizedBox(height: 16),
            Text(
              'تمرکز اصلی: بهینه‌سازی تیم با هوش مصنوعی و بهبود جریان‌های کاری.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Copy to clipboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خلاصه در کلیپ‌بورد کپی شد'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('کپی'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('انتخاب زبان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('فارسی (اصلی)'),
            _languageOption('انگلیسی'),
            _languageOption('عربی'),
            _languageOption('فرانسوی'),
            _languageOption('آلمانی'),
            _languageOption('اسپانیایی'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لغو'),
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
                Text('در حال ترجمه...'),
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
            Text('ترجمه شده به ${language}'),
          ],
        ),
        content: Text(
          language == 'انگلیسی'
              ? 'Excited to announce that we\'ve just launched our new AI-powered feature that helps teams collaborate better! After months of hard work, our team has created a solution that uses machine learning to analyze team interactions and suggest improvements to workflows and communication patterns.'
              : _post['content'],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن'),
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
            Text('بینش هوش مصنوعی'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'این پست درباره:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• راه‌اندازی محصول جدید در حوزه هوش مصنوعی و همکاری تیمی'),
            Text('• استفاده از یادگیری ماشین برای بهینه‌سازی تیم'),
            Text('• بهبود جریان کاری از طریق تحلیل داده'),
            SizedBox(height: 16),
            Text(
              'موضوعات مرتبطی که ممکن است برای شما جالب باشند:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• سنجش بهره‌وری تیم'),
            Text('• اخلاق هوش مصنوعی در نظارت بر محل کار'),
            Text('• یادگیری ماشین برای بهینه‌سازی کسب و کار'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Ask a follow-up question
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('از هوش مصنوعی درباره این پست بپرسید'),
                  content: TextField(
                    decoration: InputDecoration(
                      hintText: 'سوال خود را بنویسید...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('لغو'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: Text('پرسیدن'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('پرسیدن سوال بیشتر'),
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
            Text('ایده‌های محتوا'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بر اساس این پست، شما می‌توانید محتوایی درباره این موارد ایجاد کنید:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _contentIdeaItem(
              'چگونه هوش مصنوعی همکاری تیمی را در سال ۲۰۲۳ متحول می‌کند',
              '۷۸٪ تطابق با پروفایل شما',
            ),
            SizedBox(height: 12),
            _contentIdeaItem(
              'اخلاق استفاده از هوش مصنوعی برای نظارت بر عملکرد تیم',
              '۶۵٪ تطابق با پروفایل شما',
            ),
            SizedBox(height: 12),
            _contentIdeaItem(
              'مطالعه موردی: پیاده‌سازی هوش مصنوعی در مدیریت پروژه',
              '۸۲٪ تطابق با پروفایل شما',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate a draft post
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ایده محتوا در پیش‌نویس‌ها ذخیره شد'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('ذخیره ایده‌ها'),
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