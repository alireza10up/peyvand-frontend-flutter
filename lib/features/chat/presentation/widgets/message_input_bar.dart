import 'package:flutter/material.dart';
import 'package:peyvand/features/chat/data/providers/chat_provider.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/chat/data/models/chat_message_model.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessageInputBar extends StatefulWidget {
  final int conversationId;
  final ChatProvider chatProvider;
  final Function(ChatMessageModel? message) onMessageSent;

  const MessageInputBar({
    super.key,
    required this.conversationId,
    required this.chatProvider,
    required this.onMessageSent,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isSending = false;
  Timer? _typingTimer;
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  void _handleSend() async {
    if ((_textController.text.trim().isEmpty && _selectedImages.isEmpty) ||
        _isSending) return;

    setState(() => _isSending = true);
    widget.chatProvider.stopTyping(widget.conversationId);
    _typingTimer?.cancel();
    _typingTimer = null;

    final messageContent = _textController.text.trim();
    List<int>? attachmentFileIds;

    if (_selectedImages.isNotEmpty) {
      try {
        attachmentFileIds =
        await widget.chatProvider.uploadChatImages(_selectedImages);
        if (attachmentFileIds.isEmpty && _selectedImages.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'هیچکدام از تصاویر آپلود نشدند. لطفاً دوباره تلاش کنید.')));
          }
          setState(() => _isSending = false);
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطا در آپلود تصاویر: ${e.toString()}')));
        }
        setState(() => _isSending = false);
        return;
      }
    }

    if (messageContent.isNotEmpty ||
        (attachmentFileIds != null && attachmentFileIds.isNotEmpty)) {
      _textController.clear();
      setState(() {
        _selectedImages.clear();
      });

      final sentMessage = await widget.chatProvider.sendMessage(
        conversationId: widget.conversationId,
        content: messageContent.isNotEmpty ? messageContent : null,
        attachmentFileIds: attachmentFileIds,
      );
      widget.onMessageSent(sentMessage);
    } else if (_selectedImages.isNotEmpty &&
        (attachmentFileIds == null || attachmentFileIds.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تصاویر آپلود نشدند و متنی برای ارسال وجود ندارد.')));
      }
    }

    if (mounted) setState(() => _isSending = false);
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      if (_typingTimer == null || !_typingTimer!.isActive) {
        widget.chatProvider.startTyping(widget.conversationId);
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        widget.chatProvider.stopTyping(widget.conversationId);
      });
    } else {
      _typingTimer?.cancel();
      widget.chatProvider.stopTyping(widget.conversationId);
    }
    setState(() {});
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('در حال حاضر فقط امکان ارسال یک تصویر وجود دارد.')));
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

      if (image != null) {
        setState(() {
          if (_selectedImages.isEmpty) {
            _selectedImages.add(image);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در انتخاب تصویر: ${e.toString()}')));
      }
    }
  }

  void _removeSelectedImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }
    final imageFile = _selectedImages.first;
    return Container(
      height: 70,
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0, left: 16, right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.file(File(imageFile.path), fit: BoxFit.cover)),
            ),
            Positioned(
              top: -4,
              left: -4,
              child: InkWell(
                onTap: () => _removeSelectedImage(imageFile),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool canSend = _textController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 8.0,
        bottom: 8.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectedImagesPreview(),
            SizedBox(
              height: 50,
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                minLines: 1,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.0),
                decoration: InputDecoration(
                  hintText: 'پیام خود را بنویسید...',
                  fillColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
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
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.only(left: 0, right: 0, top:0, bottom:0),
                  isDense: true,
                  prefixIcon: _isSending
                      ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppTheme.primaryColor)),
                  )
                      : IconButton(
                    icon: Icon(Icons.send_rounded,
                        color: canSend
                            ? AppTheme.primaryColor
                            : Colors.grey.shade400,
                        size: 25),
                    onPressed: canSend ? _handleSend : null,
                    tooltip: 'ارسال',
                    splashRadius: 22,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_photo_alternate_outlined,
                        color: theme.colorScheme.secondary, size: 25),
                    onPressed: _pickImages,
                    tooltip: 'افزودن تصویر',
                    splashRadius: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}