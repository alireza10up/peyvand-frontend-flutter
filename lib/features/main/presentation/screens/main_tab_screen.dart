import 'package:flutter/material.dart';
import 'package:peyvand/features/home/presentation/screens/home_screen.dart';
import 'package:peyvand/features/profile/presentation/screens/profile_screen.dart';
import 'package:peyvand/features/posts/presentation/screens/user_posts_screen.dart';
import 'package:peyvand/features/connections/presentation/screens/network_screen.dart';
import 'package:peyvand/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:peyvand/features/chat/data/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/ai_chat/presentation/screens/ai_chat_screen.dart'; // Added

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  static const String routeName = '/main-tab';

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const NetworkScreen(),
    const UserPostsScreen(),
    const AiChatScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildChatBadge() {
    return Consumer<ChatProvider?>(
      builder: (context, chatProvider, child) {
        final unreadCount = chatProvider?.totalUnreadCount ?? 0;
        Widget icon = const Icon(Icons.chat_bubble_outline_rounded);
        Widget activeIcon = const Icon(Icons.chat_bubble_rounded);
        final currentIcon = _selectedIndex == 3 ? activeIcon : icon;

        if (unreadCount > 0) {
          return Badge(
            label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
            child: currentIcon,
          );
        }
        return currentIcon;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            activeIcon: Icon(Icons.hub_rounded),
            label: 'شبکه',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.post_add_outlined),
            activeIcon: Icon(Icons.post_add),
            label: 'پست‌ها',
          ),
          const BottomNavigationBarItem(
            // New AI Assistant Tab
            icon: Icon(Icons.assistant_outlined),
            activeIcon: Icon(Icons.assistant_rounded),
            label: 'دستیار',
          ),
          BottomNavigationBarItem(icon: _buildChatBadge(), label: 'گفتگوها'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'پروفایل',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.75),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8.0,
      ),
    );
  }
}
