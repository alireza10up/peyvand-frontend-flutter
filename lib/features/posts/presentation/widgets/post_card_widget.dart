import 'package:flutter/material.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/posts/data/models/post_status_enum.dart';

class PostCardWidget extends StatelessWidget {
  final Post post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLikeTap;
  // final int likeCount;
  // final int commentCount;
  final bool isLikedByCurrentUser;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onEdit,
    this.onDelete,
    this.onCommentTap,
    this.onLikeTap,
    // this.likeCount = 0,
    // this.commentCount = 0,
    this.isLikedByCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final ApiService apiService = ApiService();

    String formatDateTime(DateTime dateTime) {
      final formatter = intl.DateFormat('yyyy/MM/dd HH:mm', 'fa_IR');
      return formatter.format(dateTime.toLocal());
    }

    Widget _buildStatusChip(PostStatus status) {
      String text;
      Color backgroundColor;
      Color textColor = Colors.white; // Default text color for chips

      switch (status) {
        case PostStatus.published:
          text = 'منتشر شده';
          backgroundColor = Colors.deepPurpleAccent;
          break;
        case PostStatus.draft:
          text = 'پیش‌نویس';
          backgroundColor = AppTheme.secondaryTextColor;
          break;
        case PostStatus.archived:
          text = 'آرشیو شده';
          backgroundColor = Colors.orange;
          break;
        default:
          text = status.toString();
          backgroundColor = Colors.grey;
      }

      return Chip(
        label: Text(text, style: textTheme.labelSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0), // Reduce padding inside chip
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact, // Make chip smaller
      );
    }

    void _showCommentsBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ]
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // عنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'نظرات کاربران',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16.0),
                        children: const [
                          Center(
                            child: Text(
                              'بخش نظرات در اینجا پیاده‌سازی خواهد شد.\n(API و UI برای لیست نظرات لازم است)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TextButton(
                    //     child: const Text('بستن'),
                    //     onPressed: () => Navigator.of(context).pop(),
                    //   ),
                    // )
                  ],
                ),
              );
            },
          );
        },
      );
    }

    String? userAvatarUrl;
    if (post.user.profilePictureRelativeUrl != null && post.user.profilePictureRelativeUrl!.isNotEmpty) {
      userAvatarUrl = apiService.getBaseUrl() + post.user.profilePictureRelativeUrl!;
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      elevation: 3.0,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: userAvatarUrl != null ? NetworkImage(userAvatarUrl) : null,
                  child: userAvatarUrl == null
                      ? Icon(Icons.person_outline_rounded, size: 24, color: colorScheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.displayName ?? post.user.email,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatDateTime(post.createdAt),
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  SizedBox( // To constrain the size of PopupMenuButton
                    width: 40,
                    height: 40,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                      tooltip: "گزینه‌ها",
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) onEdit!();
                        else if (value == 'delete' && onDelete != null) onDelete!();
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        if (onEdit != null)
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(leading: Icon(Icons.edit_outlined, size: 20), title: Text('ویرایش', style: TextStyle(fontSize: 14))),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20), title: Text('حذف', style: TextStyle(color: Colors.red, fontSize: 14))),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (post.title != null && post.title!.isNotEmpty) ...[
              Text(
                post.title!,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18), // Slightly smaller title
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              post.content,
              style: textTheme.bodyLarge?.copyWith(height: 1.5), // Increased line height for readability
              maxLines: 5, // Allow more lines for content
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _buildStatusChip(post.status),

            if (post.files.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Text('تصاویر:', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 120, // Increased height for images
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.files.length,
                  itemBuilder: (context, index) {
                    final file = post.files[index];
                    final imageUrl = (file.url.startsWith('http') || file.url.startsWith('https'))
                        ? file.url
                        : apiService.getBaseUrl() + (file.url.startsWith('/') ? file.url : '/${file.url}');
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0), // More rounded corners for images
                        child: Image.network(
                          imageUrl,
                          width: 120, // Increased width for images
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 120, height: 120, color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30),
                          ),
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120, height: 120, color: Colors.grey.shade100,
                              child: Center(child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2.0,
                              )),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Divider(height: 32, thickness: 0.8, color: Colors.grey.shade300),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space evenly
              children: <Widget>[
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: Icon(
                    isLikedByCurrentUser ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                    size: 20,
                    color: isLikedByCurrentUser ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    "15 لایک", //  "${likeCount}
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  onPressed: onLikeTap ?? () { /* Placeholder */ },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: Icon(Icons.comment_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                  label: Text(
                    "3 نظر", // "${commentCount}
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  onPressed: onCommentTap ?? () => _showCommentsBottomSheet(context),
                ),
                TextButton.icon(
                  icon: Icon(Icons.share_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                  label: Text("اشتراک", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}