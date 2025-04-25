import 'package:flutter/material.dart';
import 'package:peyvand/ui/screens/auth/login_screen.dart';
import 'package:peyvand/ui/screens/auth/register_screen.dart';
import 'package:peyvand/ui/screens/auth/forgot_password_screen.dart';
import 'package:peyvand/ui/screens/home/home_screen.dart';
import 'package:peyvand/ui/screens/home/post_detail_screen.dart';
import 'package:peyvand/ui/screens/profile/profile_screen.dart';
import 'package:peyvand/ui/screens/profile/edit_profile_screen.dart';
import 'package:peyvand/ui/screens/profile/similar_profiles_screen.dart';
import 'package:peyvand/ui/screens/chat/chat_list_screen.dart';
import 'package:peyvand/ui/screens/chat/chat_screen.dart';
import 'package:peyvand/ui/screens/chat/ai_chat_screen.dart';
import 'package:peyvand/ui/screens/notifications/notifications_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String postDetail = '/post-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String similarProfiles = '/similar-profiles';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String aiChat = '/ai-chat';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      forgotPassword: (context) => ForgotPasswordScreen(),
      home: (context) => HomeScreen(),
      postDetail: (context) => PostDetailScreen(),
      profile: (context) => ProfileScreen(),
      editProfile: (context) => EditProfileScreen(),
      similarProfiles: (context) => SimilarProfilesScreen(),
      chatList: (context) => ChatListScreen(),
      chat: (context) => ChatScreen(),
      aiChat: (context) => AiChatScreen(),
      notifications: (context) => NotificationsScreen(),
    };
  }
}