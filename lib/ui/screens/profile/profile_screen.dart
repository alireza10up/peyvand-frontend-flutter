import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/config/routes.dart';
import 'package:peyvand/ui/widgets/profile/profile_header.dart';
import 'package:peyvand/ui/widgets/profile/skill_tag.dart';
import 'package:peyvand/ui/widgets/post/post_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> _userData = {
    'name': 'جان دو',
    'title': 'مهندس نرم‌افزار ارشد',
    'company': 'شرکت نوآوری‌های فناوری',
    'location': 'تهران، ایران',
    'connections': 487,
    'about': 'مهندس نرم‌افزار با اشتیاق و بیش از ۸ سال تجربه در توسعه برنامه‌های مقیاس‌پذیر. متخصص در توسعه موبایل و ادغام هوش مصنوعی.',
    'skills': [
      'فلاتر', 'ری‌اکت نیتیو', 'یادگیری ماشین', 'پایتون', 'جاوااسکریپت', 'نود.جی‌اس', 'فایربیس', 'AWS', 'طراحی رابط کاربری'
    ],
    'experience': [
      {
        'title': 'مهندس نرم‌افزار ارشد',
        'company': 'شرکت نوآوری‌های فناوری',
        'duration': 'ژانویه ۲۰۲۰ - تاکنون',
        'description': 'رهبری تیم توسعه موبایل و پیاده‌سازی ویژگی‌های هوش مصنوعی.',
      },
      {
        'title': 'توسعه‌دهنده موبایل',
        'company': 'راهکارهای دیجیتال',
        'duration': 'مارس ۲۰۱۷ - دسامبر ۲۰۱۹',
        'description': 'توسعه اپلیکیشن‌های چندسکویی با استفاده از فلاتر و ری‌اکت نیتیو.',
      }
    ],
    'education': [
      {
        'degree': 'کارشناسی ارشد علوم کامپیوتر',
        'school': 'دانشگاه تهران',
        'duration': '۲۰۱۵ - ۲۰۱۷',
      },
      {
        'degree': 'کارشناسی مهندسی نرم‌افزار',
        'school': 'دانشگاه صنعتی شریف',
        'duration': '۲۰۱۱ - ۲۰۱۵',
      }
    ]
  };

  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': {
        'name': 'جان دو',
        'avatar': null,
        'title': 'مهندس نرم‌افزار ارشد',
      },
      'timeAgo': '۳ روز',
      'content': 'خوشحالم که به اشتراک می‌گذارم که به تازگی یک پروژه جدید ادغام هوش مصنوعی با فلاتر را تکمیل کرده‌ام! #فلاتر #هوش_مصنوعی #توسعه_موبایل',
      'likes': 78,
      'comments': 15,
      'hasImage': true,
    },
    {
      'id': '2',
      'user': {
        'name': 'جان دو',
        'avatar': null,
        'title': 'مهندس نرم‌افزار ارشد',
      },
      'timeAgo': '۱ هفته',
      'content': 'به تازگی مقاله خود درباره "بهترین شیوه‌های ادغام هوش مصنوعی در اپلیکیشن‌های موبایل" را منتشر کرده‌ام. آن را بررسی کنید و نظر خود را به من بگویید!',
      'likes': 124,
      'comments': 32,
      'hasImage': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                'پروفایل',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: AppTheme.secondaryColor),
                  onPressed: () {},
                ),
              ],
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(userData: _userData),
              _buildActionButtons(),
              _buildTabBar(),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('ویرایش پروفایل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.editProfile);
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.people_outline),
              label: Text('یافتن افراد مشابه'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.similarProfiles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.lightTextColor,
        indicatorColor: AppTheme.primaryColor,
        tabs: [
          Tab(text: 'پست‌ها'),
          Tab(text: 'درباره'),
          Tab(text: 'فعالیت'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 1000, // Fixed height for demonstration
      child: TabBarView(
        controller: _tabController,
        children: [
          // Posts Tab
          ListView.builder(
            padding: EdgeInsets.only(top: 16),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: _posts[index]);
            },
          ),

          // About Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('درباره'),
                SizedBox(height: 8),
                Text(_userData['about']),
                SizedBox(height: 24),

                _buildSectionTitle('مهارت‌ها'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _userData['skills'].map<Widget>((skill) {
                    return SkillTag(skill: skill);
                  }).toList(),
                ),
                SizedBox(height: 24),

                _buildSectionTitle('تجربه'),
                SizedBox(height: 8),
                ..._userData['experience'].map((exp) {
                  return _buildExperienceItem(exp);
                }).toList(),
                SizedBox(height: 24),

                _buildSectionTitle('تحصیلات'),
                SizedBox(height: 8),
                ..._userData['education'].map((edu) {
                  return _buildEducationItem(edu);
                }).toList(),
              ],
            ),
          ),

          // Activity Tab
          Center(
            child: Text('فعالیت اخیری وجود ندارد'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> experience) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  experience['company'],
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Text(
                  experience['duration'],
                  style: TextStyle(
                    color: AppTheme.lightTextColor,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(experience['description']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.school,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education['degree'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  education['school'],
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Text(
                  education['duration'],
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
}