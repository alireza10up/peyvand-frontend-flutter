import 'package:flutter/material.dart';
import 'package:peyvand/features/posts/data/models/comment_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:intl/intl.dart' as intl;

class CommentsBottomSheetWidget extends StatefulWidget {
  final int postId;
  final String currentUserId;

  const CommentsBottomSheetWidget({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<CommentsBottomSheetWidget> createState() =>
      _CommentsBottomSheetWidgetState();
}

class _CommentsBottomSheetWidgetState extends State<CommentsBottomSheetWidget> {
  final PostService _postService = PostService();
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  bool _isPostingComment = false;
  String? _errorMessage;

  Map<int, bool> _isLoadingRepliesMap = {};
  Map<int, List<Comment>> _loadedRepliesMap = {};
  Map<int, bool> _showRepliesMap = {};

  int? _replyingToCommentId;
  String? _replyingToUsername;
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments({bool scrollToBottom = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingComments = true;
      _errorMessage = null;
    });
    try {
      final comments = await _postService.getCommentsForPost(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
        if (scrollToBottom && _comments.isNotEmpty) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "خطا در بارگذاری نظرات.";
          _isLoadingComments = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _postNewComment() async {
    if (_commentController.text.trim().isEmpty || _isPostingComment) return;
    setState(() {
      _isPostingComment = true;
    });

    try {
      Comment newCommentEntity;

      if (_replyingToCommentId != null) {
        newCommentEntity = await _postService.addReplyToComment(
          _replyingToCommentId!,
          _commentController.text.trim(),
        );
        if (mounted) {
          _fetchReplies(_replyingToCommentId!, scrollToNewReply: true);

          final parentCommentIndex = _comments.indexWhere(
            (c) => c.id == _replyingToCommentId,
          );
          if (parentCommentIndex != -1) {
            final parentComment = _comments[parentCommentIndex];
            _comments[parentCommentIndex] = parentComment.copyWith(
              replyCount: parentComment.replyCount + 1,
            );
            setState(() {});
          }
        }
      } else {
        newCommentEntity = await _postService.addCommentToPost(
          widget.postId,
          _commentController.text.trim(),
        );
        if (mounted) {
          setState(() {
            _comments.add(newCommentEntity);
          });
          _scrollToBottom();
        }
      }
      _commentController.clear();
      _cancelReply();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ارسال: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isPostingComment = false;
        });
    }
  }

  Future<void> _fetchReplies(
    int parentCommentId, {
    bool scrollToNewReply = false,
  }) async {
    if (!mounted ||
        (_isLoadingRepliesMap[parentCommentId] == true && !scrollToNewReply))
      return;
    setState(() {
      _isLoadingRepliesMap[parentCommentId] = true;
      _showRepliesMap[parentCommentId] = true;
    });
    try {
      final replies = await _postService.getRepliesForComment(parentCommentId);
      if (mounted) {
        setState(() {
          _loadedRepliesMap[parentCommentId] = replies;
          _isLoadingRepliesMap[parentCommentId] = false;
        });
        if (scrollToNewReply && replies.isNotEmpty) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoadingRepliesMap[parentCommentId] = false;
        });
    }
  }

  void _toggleShowReplies(int commentId) {
    setState(() {
      final currentlyShowing = _showRepliesMap[commentId] ?? false;
      _showRepliesMap[commentId] = !currentlyShowing;

      if (_showRepliesMap[commentId] == true &&
          (_loadedRepliesMap[commentId] == null ||
              _loadedRepliesMap[commentId]!.isEmpty)) {
        Comment? mainComment;
        try {
          mainComment = _comments.firstWhere((c) => c.id == commentId);
        } catch (e) {
          print(e.toString());
        }
        if (mainComment != null && mainComment.replyCount > 0) {
          _fetchReplies(commentId);
        } else if (mainComment != null && mainComment.replyCount == 0) {
          if (mounted)
            setState(() {
              _isLoadingRepliesMap[commentId] = false;
            });
        }
      }
    });
  }

  void _startReply(Comment commentToReply) {
    setState(() {
      _replyingToCommentId = commentToReply.id;
      _replyingToUsername =
          commentToReply.user.displayName ?? commentToReply.user.email;
      _commentFocusNode.requestFocus();
      _commentController.text = '';
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  Future<void> _deleteCommentOrReply(
    int commentOrReplyId, {
    int? parentIdIfReply,
  }) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تایید حذف'),
          content: const Text('آیا از حذف این مورد مطمئن هستید؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('لغو'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      try {
        await _postService.deleteComment(commentOrReplyId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('با موفقیت حذف شد.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            if (parentIdIfReply != null) {
              _loadedRepliesMap[parentIdIfReply]?.removeWhere(
                (reply) => reply.id == commentOrReplyId,
              );
              final parentCommentIndex = _comments.indexWhere(
                (c) => c.id == parentIdIfReply,
              );
              if (parentCommentIndex != -1) {
                final pc = _comments[parentCommentIndex];
                if (pc.replyCount > 0)
                  _comments[parentCommentIndex] = pc.copyWith(
                    replyCount: pc.replyCount - 1,
                  );
              }
            } else {
              _comments.removeWhere(
                (comment) => comment.id == commentOrReplyId,
              );
              _loadedRepliesMap.remove(commentOrReplyId);
              _showRepliesMap.remove(commentOrReplyId);
              _isLoadingRepliesMap.remove(commentOrReplyId);
            }
          });
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در حذف: ${e.toString()}')),
          );
      }
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 5) return 'همین حالا';
    if (difference.inMinutes < 1) return '${difference.inSeconds} ثانیه پیش';
    if (difference.inHours < 1) return '${difference.inMinutes} دقیقه پیش';
    if (difference.inDays < 1) return '${difference.inHours} ساعت پیش';
    if (difference.inDays < 7) return '${difference.inDays} روز پیش';
    return intl.DateFormat('yyyy/MM/dd', 'fa_IR').format(dateTime);
  }

  Widget _buildCommentItem(Comment comment, {bool isReply = false}) {
    final theme = Theme.of(context);
    String? avatarUrl;
    if (comment.user.profilePictureRelativeUrl != null &&
        comment.user.profilePictureRelativeUrl!.isNotEmpty) {
      avatarUrl =
          _apiService.getBaseUrl() + comment.user.profilePictureRelativeUrl!;
    }
    final bool shouldShowReplies = _showRepliesMap[comment.id] ?? false;
    final bool isLoadingThisReplySet =
        _isLoadingRepliesMap[comment.id] ?? false;
    final List<Comment> currentReplies = _loadedRepliesMap[comment.id] ?? [];

    return Padding(
      padding: EdgeInsets.only(
        left: (isReply ? 25.0 : 0.0),
        top: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 16 : 20,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child:
                    avatarUrl == null
                        ? Icon(
                          Icons.person_rounded,
                          size: isReply ? 18 : 22,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            comment.user.displayName ?? comment.user.email,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (comment.user.id.toString() == widget.currentUserId)
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.error,
                                size: 18,
                              ),
                              onPressed:
                                  () => _deleteCommentOrReply(
                                    comment.id,
                                    parentIdIfReply: comment.parentId,
                                  ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: "حذف",
                              splashRadius: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.85,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatRelativeTime(comment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        if (!isReply) ...[
                          const SizedBox(width: 16),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _startReply(comment),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  'پاسخ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replyCount > 0 && !isReply)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 6.0),
              child: InkWell(
                onTap: () => _toggleShowReplies(comment.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isLoadingThisReplySet
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(
                            shouldShowReplies
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            size: 22,
                            color: theme.colorScheme.secondary,
                          ),
                      const SizedBox(width: 6),
                      Text(
                        shouldShowReplies
                            ? 'مخفی کردن پاسخ‌ها'
                            : (isLoadingThisReplySet
                                ? 'بارگذاری...'
                                : 'مشاهده ${comment.replyCount} پاسخ'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (shouldShowReplies && currentReplies.isNotEmpty && !isReply)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children:
                    currentReplies
                        .map((reply) => _buildCommentItem(reply, isReply: true))
                        .toList(),
              ),
            ),
          if (shouldShowReplies &&
              isLoadingThisReplySet &&
              currentReplies.isEmpty &&
              !isReply)
            const Padding(
              padding: EdgeInsets.only(left: 40.0, top: 8.0),
              child: Text(
                "درحال بارگذاری پاسخ ها...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          if (shouldShowReplies &&
              !isLoadingThisReplySet &&
              currentReplies.isEmpty &&
              comment.replyCount > 0 &&
              !isReply)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 8.0),
              child: Text(
                "هنوز پاسخی ثبت نشده است.",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // itemBuilder: (context, index) {
    //   return _buildCommentItem(_comments[index]);
    // },
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: theme.canvasColor,
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'نظرات',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child:
                  _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade300,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text("تلاش مجدد"),
                                onPressed: _fetchComments,
                              ),
                            ],
                          ),
                        ),
                      )
                      : _comments.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'اولین نفری باشید که نظر می‌دهد!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _fetchComments,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(_comments[index]);
                          },
                          separatorBuilder:
                              (context, index) => const Divider(
                                height: 16,
                                thickness: 0.5,
                                indent: 50,
                                endIndent: 10,
                              ),
                        ),
                      ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 10.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingToCommentId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "پاسخ به: ${_replyingToUsername ?? ''}",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: _cancelReply,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocusNode,
                          decoration: InputDecoration(
                            hintText:
                                _replyingToCommentId != null
                                    ? 'پاسخ خود را بنویسید...'
                                    : 'نظر خود را بنویسید...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.8,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.2,
                              ),
                            ),
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            isDense: true,
                            suffixIcon:
                                _isPostingComment
                                    ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                    )
                                    : IconButton(
                                      icon: Icon(
                                        Icons.send_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                      onPressed: _postNewComment,
                                      tooltip: "ارسال",
                                      splashRadius: 20,
                                      padding: EdgeInsets.zero,
                                    ),
                          ),
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height:
                        10.0 +
                        (MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom - 8
                            : 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
