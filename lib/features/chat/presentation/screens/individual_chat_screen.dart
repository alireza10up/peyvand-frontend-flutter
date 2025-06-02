import 'package:flutter/material.dart';
import 'package:peyvand/features/chat/data/models/chat_user_model.dart';
import 'package:peyvand/features/chat/data/providers/chat_provider.dart';
import 'package:peyvand/features/chat/data/models/chat_message_model.dart';
import 'package:peyvand/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:peyvand/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/profile/presentation/screens/other_user_profile_screen.dart';

import '../../data/providers/chat_provider.dart';

class IndividualChatScreen extends StatefulWidget {
  final int conversationId;
  final ChatUserModel otherParticipant;
  final ChatProvider chatProvider;

  const IndividualChatScreen({
    super.key,
    required this.conversationId,
    required this.otherParticipant,
    required this.chatProvider,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isInitiallyLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.chatProvider.joinConversation(widget.conversationId);
        _loadMessages();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        // TODO: Implement load more messages logic if needed
        // widget.chatProvider.fetchMessages(widget.conversationId, loadMore: true);
      }
    });
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isInitiallyLoading = true);
    await widget.chatProvider.fetchMessages(widget.conversationId);
    if (mounted) setState(() => _isInitiallyLoading = false);
    _scrollToBottom(milliseconds: 300);
  }

  @override
  void dispose() {
    widget.chatProvider.leaveConversation(widget.conversationId);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({int milliseconds = 100}) {
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      Future.delayed(Duration(milliseconds: milliseconds), () {
        if (mounted &&
            _scrollController.hasClients &&
            _scrollController.position.hasContentDimensions) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onMessageSent(ChatMessageModel? message) {
    if (message != null) {
      _scrollToBottom();
    }
  }

  void _navigateToUserProfile(String userId) {
    Navigator.of(context)
        .pushNamed(OtherUserProfileScreen.routeName, arguments: userId);
  }

  @override
  Widget build(BuildContext context) {
    String? avatarUrl;
    if (widget.otherParticipant.profilePictureRelativeUrl != null &&
        widget.otherParticipant.profilePictureRelativeUrl!.isNotEmpty) {
      avatarUrl =
          _apiService.getBaseUrl() + widget.otherParticipant.profilePictureRelativeUrl!;
    }

    return ChangeNotifierProvider.value(
      value: widget.chatProvider,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 30,
          title: InkWell(
            onTap: () => _navigateToUserProfile(widget.otherParticipant.id),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(widget.otherParticipant.displayName
                      ?.substring(0, 1)
                      .toUpperCase() ??
                      "?")
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.otherParticipant.displayName ??
                            widget.otherParticipant.email ??
                            'کاربر',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Consumer<ChatProvider>(
                        builder: (context, provider, _) {
                          final typingUser = provider
                              .typingUsersByConversation[widget.conversationId];
                          if (typingUser != null &&
                              typingUser.id == widget.otherParticipant.id) {
                            return Text(
                              'در حال نوشتن...',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                  AppTheme.accentColor.withOpacity(0.9)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (_isInitiallyLoading &&
                      provider.isLoadingMessages(widget.conversationId) &&
                      provider.getMessagesForConversation(widget.conversationId).isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages =
                  provider.getMessagesForConversation(widget.conversationId);
                  if (messages.isEmpty &&
                      !provider.isLoadingMessages(widget.conversationId)) {
                    return const Center(
                      child: Text(
                          'هنوز پیامی در این گفتگو وجود ندارد.\nاولین پیام را شما ارسال کنید!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (messages.isNotEmpty && mounted) _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message.sender.id == provider?.currentUserProfile.id;
                      return ChatBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            MessageInputBar(
              conversationId: widget.conversationId,
              chatProvider: widget.chatProvider,
              onMessageSent: _onMessageSent,
            ),
          ],
        ),
      ),
    );
  }
}