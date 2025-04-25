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
    'name': 'John Doe',
    'title': 'Senior Software Engineer',
    'company': 'Tech Innovations Inc.',
    'location': 'Tehran, Iran',
    'connections': 487,
    'about': 'Passionate software engineer with over 8 years of experience in developing scalable applications. Specialized in mobile development and AI integration.',
    'skills': [
      'Flutter', 'React Native', 'Machine Learning', 'Python', 'JavaScript', 'Node.js', 'Firebase', 'AWS', 'UI/UX Design'
    ],
    'experience': [
      {
        'title': 'Senior Software Engineer',
        'company': 'Tech Innovations Inc.',
        'duration': 'Jan 2020 - Present',
        'description': 'Leading mobile development team and implementing AI features.',
      },
      {
        'title': 'Mobile Developer',
        'company': 'Digital Solutions Ltd.',
        'duration': 'Mar 2017 - Dec 2019',
        'description': 'Developed cross-platform mobile applications using Flutter and React Native.',
      }
    ],
    'education': [
      {
        'degree': 'Master of Computer Science',
        'school': 'University of Tehran',
        'duration': '2015 - 2017',
      },
      {
        'degree': 'Bachelor of Software Engineering',
        'school': 'Sharif University of Technology',
        'duration': '2011 - 2015',
      }
    ]
  };

  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'user': {
        'name': 'John Doe',
        'avatar': null,
        'title': 'Senior Software Engineer',
      },
      'timeAgo': '3d',
      'content': 'Excited to share that I\'ve just completed a new project integrating AI with Flutter! #Flutter #AI #MobileDevelopment',
      'likes': 78,
      'comments': 15,
      'hasImage': true,
    },
    {
      'id': '2',
      'user': {
        'name': 'John Doe',
        'avatar': null,
        'title': 'Senior Software Engineer',
      },
      'timeAgo': '1w',
      'content': 'Just published my article on "Best Practices for AI Integration in Mobile Apps". Check it out and let me know your thoughts!',
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
                'Profile',
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
              label: Text('Edit Profile'),
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
              label: Text('Find Similar'),
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
          Tab(text: 'Posts'),
          Tab(text: 'About'),
          Tab(text: 'Activity'),
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
                _buildSectionTitle('About'),
                SizedBox(height: 8),
                Text(_userData['about']),
                SizedBox(height: 24),

                _buildSectionTitle('Skills'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _userData['skills'].map<Widget>((skill) {
                    return SkillTag(skill: skill);
                  }).toList(),
                ),
                SizedBox(height: 24),

                _buildSectionTitle('Experience'),
                SizedBox(height: 8),
                ..._userData['experience'].map((exp) {
                  return _buildExperienceItem(exp);
                }).toList(),
                SizedBox(height: 24),

                _buildSectionTitle('Education'),
                SizedBox(height: 8),
                ..._userData['education'].map((edu) {
                  return _buildEducationItem(edu);
                }).toList(),
              ],
            ),
          ),

          // Activity Tab
          Center(
            child: Text('No recent activity'),
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