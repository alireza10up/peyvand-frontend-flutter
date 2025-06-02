import 'package:flutter/material.dart';
import 'package:peyvand/features/chat/data/providers/chat_provider.dart';
import 'package:peyvand/features/chat/presentation/widgets/select_connection_bottom_sheet.dart';
import 'package:peyvand/features/chat/presentation/screens/individual_chat_screen.dart';
import 'package:peyvand/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/chat/presentation/widgets/select_connection_dialog.dart';
import 'package:peyvand/features/chat/data/models/chat_user_model.dart' as chat_user_model;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ChatProvider? _chatProvider;
  final ApiService _apiService = ApiService();
  bool _isChatProviderInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer ChatProvider initialization and data fetching until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          // Initialize ChatProvider here, now that context is safely available
          _chatProvider = ChatProvider(authProvider.currentUserId!, authProvider.currentUser!);
          setState(() {
            _isChatProviderInitialized = true; // Mark as initialized
          });
          _chatProvider!.fetchConversations(forceRefresh: true);
        } else {
          // Handle not authenticated case, e.g., show a message or pop
          if (Navigator.canPop(context)) {
            // Navigator.of(context).pop(); // Or navigate to login
          }
        }
      }
    });
  }

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return intl.DateFormat.Hm('fa_IR').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'دیروز';
    } else if (now.difference(dateTime).inDays < 7) {
      return intl.DateFormat.EEEE('fa_IR').format(dateTime);
    } else {
      return intl.DateFormat('yyyy/MM/dd', 'fa_IR').format(dateTime);
    }
  }

  void _startNewChatWithSelectedUser(chat_user_model.ChatUserModel selectedUser) async {
    if (!_isChatProviderInitialized || _chatProvider == null || _chatProvider!.currentUserProfile == null) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final conversation = await _chatProvider!.createOrGetConversationWithUser(int.parse(selectedUser.id));

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (conversation != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IndividualChatScreen(
            conversationId: conversation.id,
            otherParticipant: selectedUser,
            chatProvider: _chatProvider!,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در شروع گفتگو با کاربر انتخابی.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChatProviderInitialized) {
      // Show a loading indicator or an empty state while ChatProvider is being initialized
      return Scaffold(
        appBar: AppBar(title: const Text('گفتگوها')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If not authenticated after attempt to initialize
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('گفتگوها')),
          body: const Center(child: Text("برای مشاهده گفتگوها ابتدا وارد شوید."))
      );
    }

    return ChangeNotifierProvider.value(
      value: _chatProvider!, // Now _chatProvider is guaranteed to be initialized
      child: Scaffold(
        appBar: AppBar(
          title: const Text('گفتگوها'),
          actions: [
            Consumer<ChatProvider>(
              builder: (context, provider, _) => IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => provider.fetchConversations(forceRefresh: true),
                tooltip: 'بارگذاری مجدد',
              ),
            )
          ],
        ),
        body: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingConversations && provider.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.conversations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'هنوز گفتگویی شروع نکرده‌اید.',
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'با دوستان خود گفتگو کنید.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_comment_outlined),
                        label: const Text("شروع گفتگوی جدید"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return SelectConnectionForChatDialog(
                                onUserSelected: (selectedUser) {
                                  _startNewChatWithSelectedUser(selectedUser);
                                },
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchConversations(forceRefresh: true),
              child: ListView.separated(
                itemCount: provider.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = provider.conversations[index];
                  final otherParticipant = conversation.getOtherParticipant(provider.currentUserProfile.id);
                  String? avatarUrl;
                  if (otherParticipant.profilePictureRelativeUrl != null &&
                      otherParticipant.profilePictureRelativeUrl!.isNotEmpty) {
                    avatarUrl = _apiService.getBaseUrl() + otherParticipant.profilePictureRelativeUrl!;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(otherParticipant.displayName?.substring(0, 1).toUpperCase() ?? "?", style: const TextStyle(fontSize: 20, color: Colors.white))
                          : null,
                      backgroundColor: avatarUrl == null ? AppTheme.primaryColor.withOpacity(0.7) : Colors.transparent,
                    ),
                    title: Text(
                      otherParticipant.displayName ?? otherParticipant.email ?? 'کاربر پیوند',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      conversation.lastMessage?.content ?? 'هنوز پیامی ارسال نشده',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTimestamp(conversation.lastMessage?.createdAt ?? conversation.updatedAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IndividualChatScreen(
                            conversationId: conversation.id,
                            otherParticipant: otherParticipant,
                            chatProvider: provider,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 0.5, indent: 80, color: Colors.grey.shade200),
              ),
            );
          },
        ),
        floatingActionButton: Consumer<ChatProvider>(
          builder: (context, provider, _) => FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext dialogContext) {
                  return SelectConnectionBottomSheet(
                    onUserSelected: (selectedUser) {
                      _startNewChatWithSelectedUser(selectedUser);
                    },
                  );
                },
              );
            },
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_comment_rounded),
            tooltip: 'گفتگوی جدید',
          ),
        ),      ),
    );
  }
}