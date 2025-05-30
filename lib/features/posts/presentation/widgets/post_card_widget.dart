import 'package:flutter/material.dart';
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/posts/data/models/post_status_enum.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/providers/auth_provider.dart';
import 'comments_bottom_sheet.dart';

class PostCardWidget extends StatefulWidget {
  final Post initialPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showStatusChip;
  final Function(String userId)? onTapUserProfile;
  final VoidCallback? onTapCard;

  const PostCardWidget({
    super.key,
    required this.initialPost,
    this.onEdit,
    this.onDelete,
    this.showStatusChip = true,
    this.onTapUserProfile,
    this.onTapCard,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  late Post post;
  late int likeCount;
  late bool isLikedByCurrentUser;
  bool _isLoadingLikeDetails = true;
  bool _isTogglingLike = false;

  final PostService _postService = PostService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    post = widget.initialPost;
    _fetchPostLikeDetails();
  }

  Future<void> _fetchPostLikeDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLikeDetails = true;
    });
    try {
      final Map<String, dynamic> likeDetails =
      await _postService.getPostLikeDetails(post.id);

      if (mounted) {
        setState(() {
          likeCount = likeDetails['count'] as int;
          isLikedByCurrentUser = likeDetails['isLikedByCurrentUser'] as bool;
          _isLoadingLikeDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error fetching like details for post ${post.id}: $e");
        setState(() {
          _isLoadingLikeDetails = false;
          likeCount = 0;
          isLikedByCurrentUser = false;
        });
      }
    }
  }

  Future<void> _handleLikeButtonTap() async {
    if (_isTogglingLike || _isLoadingLikeDetails) return;

    setState(() {
      _isTogglingLike = true;
    });

    try {
      final Map<String, dynamic> toggleResult =
      await _postService.toggleLikePost(post.id);

      if (mounted) {
        setState(() {
          likeCount = toggleResult['count'] as int;
          isLikedByCurrentUser = toggleResult['isLikedByCurrentUser'] as bool;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error toggling like for post ${post.id}: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطا در عملیات لایک.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingLike = false;
        });
      }
    }
  }

  String formatDateTime(DateTime dateTime) {
    final formatter = intl.DateFormat('yyyy/MM/dd HH:mm', 'fa_IR');
    return formatter.format(dateTime.toLocal());
  }

  Widget _buildStatusChip(PostStatus status) {
    String text;
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData? iconData;

    switch (status) {
      case PostStatus.published:
        text = 'منتشر شده';
        backgroundColor = AppTheme.accentColor;
        textColor = Colors.black87;
        iconData = Icons.public_rounded;
        break;
      case PostStatus.draft:
        text = 'پیش‌نویس';
        backgroundColor = AppTheme.primaryColor.withOpacity(0.65);
        textColor = Colors.white;
        iconData = Icons.edit_note_rounded;
        break;
      case PostStatus.archived:
        text = 'آرشیو شده';
        backgroundColor = Colors.deepPurple.shade200;
        textColor = Colors.black.withOpacity(0.7);
        iconData = Icons.inventory_2_outlined;
        break;
      default: // Should not happen if status is always valid
        text = status.toString().split('.').last; // Fallback
        backgroundColor = Colors.grey.shade400;
        iconData = Icons.label_important_outline_rounded;
    }

    return Chip(
      avatar:
      iconData != null ? Icon(iconData, color: textColor, size: 15) : null,
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      labelPadding:
      iconData != null ? const EdgeInsets.only(right: 6.0) : null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentUserId = authProvider.currentUserId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برای مشاهده یا ارسال نظر، ابتدا وارد شوید.'),
        ),
      );
      return;
    }

    if (post.status != PostStatus.published) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'فقط برای پست‌های منتشر شده می‌توانید نظر ارسال کنید یا نظرات را ببینید.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, //
          minChildSize: 0.4, //
          maxChildSize: 0.85, //
          expand: false,
          builder: (_, scrollController) {
            return CommentsBottomSheetWidget(
              postId: post.id,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    String? userAvatarUrl;
    if (post.user.profilePictureRelativeUrl != null &&
        post.user.profilePictureRelativeUrl!.isNotEmpty) {
      userAvatarUrl =
          _apiService.getBaseUrl() + post.user.profilePictureRelativeUrl!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      elevation: 3.0,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTapCard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: widget.onTapUserProfile != null && post.user.id.isNotEmpty
                    ? () => widget.onTapUserProfile!(post.user.id)
                    : null,
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: userAvatarUrl != null
                            ? NetworkImage(userAvatarUrl)
                            : null,
                        child: userAvatarUrl == null
                            ? Icon(
                          Icons.person_outline_rounded,
                          size: 24,
                          color: colorScheme.onSurfaceVariant,
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.user.displayName ?? post.user.email,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatDateTime(post.createdAt),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onEdit != null || widget.onDelete != null)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            tooltip: "گزینه‌ها",
                            onSelected: (value) {
                              if (value == 'edit' && widget.onEdit != null) {
                                widget.onEdit!();
                              } else if (value == 'delete' &&
                                  widget.onDelete != null) {
                                widget.onDelete!();
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              if (widget.onEdit != null)
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit_outlined, size: 20),
                                    title: Text('ویرایش', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              if (widget.onDelete != null)
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                    title: Text('حذف', style: TextStyle(color: Colors.red, fontSize: 14)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (post.title != null && post.title!.isNotEmpty) ...[
                Text(
                  post.title!,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                post.content,
                style: textTheme.bodyLarge?.copyWith(height: 1.5),
                  maxLines: widget.onTapCard != null ? 5 : null,
                  overflow: widget.onTapCard != null ? TextOverflow.ellipsis : TextOverflow.visible  ),
              const SizedBox(height: 10),
              if (widget.showStatusChip) ...[
                _buildStatusChip(post.status),
                const SizedBox(height: 10),
              ],
              if (post.files.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.files.length,
                    itemBuilder: (context, index) {
                      final file = post.files[index];
                      final imageUrl = (file.url.startsWith('http') ||
                          file.url.startsWith('https'))
                          ? file.url
                          : _apiService.getBaseUrl() +
                          (file.url.startsWith('/')
                              ? file.url
                              : '/${file.url}');
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                            loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                                ) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress
                                        .expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Divider(height: 32, thickness: 0.8, color: Colors.grey.shade300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: _isTogglingLike || _isLoadingLikeDetails
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                        : Icon(
                      isLikedByCurrentUser
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 20,
                      color: isLikedByCurrentUser
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      _isLoadingLikeDetails ? "..." : "$likeCount لایک",
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    onPressed:
                    _isLoadingLikeDetails ? null : _handleLikeButtonTap,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      "نظرات",
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    onPressed: () {
                      if (post.status == PostStatus.published) {
                        _showCommentsBottomSheet(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('فقط برای پست‌های منتشر شده می‌توانید نظر ارسال کنید یا نظرات را ببینید.'))
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}