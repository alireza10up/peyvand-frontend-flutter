import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class SimilarProfilesScreen extends StatefulWidget {
  @override
  _SimilarProfilesScreenState createState() => _SimilarProfilesScreenState();
}

class _SimilarProfilesScreenState extends State<SimilarProfilesScreen> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() async {
    // Simulate API call to get similar profiles
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _profiles.addAll([
        {
          'id': '1',
          'name': 'امیلی ژانگ',
          'title': 'توسعه‌دهنده ارشد موبایل',
          'company': 'تک‌گروث',
          'matchScore': 92,
          'commonSkills': ['فلاتر', 'توسعه موبایل', 'فایربیس'],
          'avatar': null,
          'isConnected': false,
        },
        {
          'id': '2',
          'name': 'الکس جانسون',
          'title': 'مهندس نرم‌افزار ارشد',
          'company': 'اینوویت‌تک',
          'matchScore': 87,
          'commonSkills': ['ری‌اکت نیتیو', 'جاوااسکریپت', 'AWS'],
          'avatar': null,
          'isConnected': true,
        },
        {
          'id': '3',
          'name': 'سارا احمدی',
          'title': 'متخصص ادغام هوش مصنوعی',
          'company': 'دیتامایندز',
          'matchScore': 85,
          'commonSkills': ['یادگیری ماشین', 'پایتون', 'هوش مصنوعی'],
          'avatar': null,
          'isConnected': false,
        },
        {
          'id': '4',
          'name': 'مایکل چن',
          'title': 'توسعه‌دهنده فول‌استک',
          'company': 'وب‌سولوشنز',
          'matchScore': 78,
          'commonSkills': ['نود.جی‌اس', 'جاوااسکریپت', 'رابط کاربری'],
          'avatar': null,
          'isConnected': false,
        },
        {
          'id': '5',
          'name': 'پریا پاتل',
          'title': 'معمار اپلیکیشن موبایل',
          'company': 'موبایل‌فرست',
          'matchScore': 76,
          'commonSkills': ['فلاتر', 'فایربیس', 'طراحی رابط کاربری'],
          'avatar': null,
          'isConnected': false,
        },
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'متخصصان مشابه',
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
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildProfileList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'در حال یافتن متخصصان مشابه...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'هوش مصنوعی ما در حال تحلیل مهارت‌ها و تجربیات است',
            style: TextStyle(
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Column(
      children: [
        _buildAiInsightCard(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8, bottom: 16),
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              return _buildProfileCard(profile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            Color(0xFFFF9A3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'بینش هوش مصنوعی',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'ما ۵ متخصص با مهارت‌ها و تجربیات مشابه پیدا کردیم. ارتباط با آنها می‌تواند شبکه شما را در زمینه‌های توسعه موبایل و هوش مصنوعی گسترش دهد.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    profile['name'].substring(0, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        profile['title'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        profile['company'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${profile['matchScore']}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'تطابق',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'مهارت‌های مشترک:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (profile['commonSkills'] as List<String>).map((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'پیشنهاد هوش مصنوعی: "پتانسیل عالی برای همکاری"',
                  style: TextStyle(
                    color: AppTheme.lightTextColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                profile['isConnected']
                    ? OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  child: Text(
                    'متصل شده',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                )
                    : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      profile['isConnected'] = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  child: Text(
                    'ارتباط',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}