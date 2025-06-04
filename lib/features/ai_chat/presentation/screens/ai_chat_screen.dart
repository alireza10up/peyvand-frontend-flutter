import 'package:flutter/material.dart';
import 'package:peyvand/config/app_assets.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/ai_chat/data/models/ai_chat_message_dto.dart';
import 'package:peyvand/services/ai_service.dart';
import 'package:peyvand/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart' as profile_user_model;
import 'package:peyvand/features/ai_chat/presentation/widgets/ai_chat_bubble.dart';
import 'package:peyvand/errors/api_exception.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  static const String routeName = '/ai-chat';

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AiMessageDto> _messages = [];
  bool _isLoadingResponse = false;
  profile_user_model.User? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserProfile = authProvider.currentUser;
    _addInitialAssistantMessage();
  }

  void _addInitialAssistantMessage() {
    setState(() {
      _messages.add(AiMessageDto(role: "assistant", content: "سلام ${_currentUserProfile?.firstName ?? 'کچ جان'}! من دستیار هوشمند پیوند هستم. چطور میتونم کمکت کنم؟"));
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoadingResponse) return;

    _textController.clear();
    final userMessage = AiMessageDto(role: "user", content: text);
    setState(() {
      _messages.add(userMessage);
      _isLoadingResponse = true;
    });
    _scrollToBottom();

    try {
      final response = await _aiService.getAiChatCompletion(_messages, _currentUserProfile);
      final assistantMessageContent = response['response'] as String? ?? "متاسفانه نتوانستم پاسخ مناسبی پیدا کنم.";
      final assistantMessage = AiMessageDto(role: "assistant", content: assistantMessageContent);
      setState(() {
        _messages.add(assistantMessage);
      });
    } on ApiException catch (e) {
      final errorMessage = AiMessageDto(role: "assistant", content: "خطا در ارتباط با دستیار: ${e.toString()}");
      setState(() {
        _messages.add(errorMessage);
      });
    }
    catch (e) {
      final errorMessage = AiMessageDto(role: "assistant", content: "یک خطای غیرمنتظره رخ داد.");
      setState(() {
        _messages.add(errorMessage);
      });
    } finally {
      setState(() {
        _isLoadingResponse = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AppAssets.logoSmall(color: AppTheme.accentColor, backgroundColor: Colors.transparent),
            const SizedBox(width: 8),
            const Text('دستیار هوشمند پیوند'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length + (_isLoadingResponse ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoadingResponse && index == _messages.length) {
                  return AiChatBubble(
                    message: AiMessageDto(role: "assistant", content: "..."),
                    isUser: false,
                    showAvatar: true,
                  );
                }
                final message = _messages[index];
                final isUser = message.role == "user";
                bool showAvatarForAssistant = true;
                if(!isUser && index > 0 && _messages[index-1].role == "assistant") {
                  showAvatarForAssistant = false;
                }


                return AiChatBubble(
                  message: message,
                  isUser: isUser,
                  showAvatar: isUser ? false : showAvatarForAssistant,
                  profileImageUrl: isUser ? (_currentUserProfile?.profilePictureRelativeUrl) : null,
                  userFirstName: isUser ? (_currentUserProfile?.firstName) : null,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 8.0,
              bottom: 8.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'پیام خود را بنویسید...',
                        fillColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary, size: 28),
                    onPressed: _sendMessage,
                    tooltip: 'ارسال',
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}