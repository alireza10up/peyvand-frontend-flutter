import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileHeader({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverAndAvatar(),
          SizedBox(height: 12),
          Text(
            userData['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            userData['title'],
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: AppTheme.lightTextColor,
              ),
              SizedBox(width: 4),
              Text(
                userData['company'],
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.lightTextColor,
              ),
              SizedBox(width: 4),
              Text(
                userData['location'],
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.people,
                size: 16,
                color: AppTheme.lightTextColor,
              ),
              SizedBox(width: 4),
              Text(
                '${userData['connections']} connections',
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

  Widget _buildCoverAndAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover photo
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Profile picture
        Positioned(
          bottom: -40,
          left: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                userData['name'].substring(0, 2).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Edit cover button
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              size: 18,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}