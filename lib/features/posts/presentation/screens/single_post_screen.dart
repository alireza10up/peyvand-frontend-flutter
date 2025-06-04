import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/profile/presentation/screens/other_user_profile_screen.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/posts/presentation/widgets/comments_bottom_sheet.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class SinglePostScreen extends StatefulWidget {
  static const String routeName = '/single-post';
  final Post post;

  const SinglePostScreen({super.key, required this.post});

  @override
  State<SinglePostScreen> createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  final PostService _postService = PostService();
  final ApiService _apiService = ApiService();

  late int likeCount;
  late bool isLikedByCurrentUser;
  bool _isLoadingLikeDetails = true;
  bool _isTogglingLike = false;
  String? _currentUserId;

  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _currentUserId = authProvider.currentUserId;
        _fetchPostLikeDetails();
      }
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostLikeDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLikeDetails = true;
    });
    try {
      final Map<String, dynamic> likeDetails = await _postService
          .getPostLikeDetails(widget.post.id);

      if (mounted) {
        setState(() {
          likeCount = likeDetails['count'] as int;
          isLikedByCurrentUser = likeDetails['isLikedByCurrentUser'] as bool;
          _isLoadingLikeDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print(
          "Error fetching like details for single post ${widget.post.id}: $e",
        );
        setState(() {
          _isLoadingLikeDetails = false;
          likeCount = 0;
          isLikedByCurrentUser = false;
        });
      }
    }
  }

  Future<void> _handleLikeButtonTap() async {
    if (_isTogglingLike || _isLoadingLikeDetails || _currentUserId == null)
      return;

    setState(() {
      _isTogglingLike = true;
    });

    try {
      final Map<String, dynamic> toggleResult = await _postService
          .toggleLikePost(widget.post.id);

      if (mounted) {
        setState(() {
          likeCount = toggleResult['count'] as int;
          isLikedByCurrentUser = toggleResult['isLikedByCurrentUser'] as bool;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error toggling like for single post ${widget.post.id}: $e");
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

  void _navigateToUserProfile(String userId) {
    Navigator.of(
      context,
    ).pushNamed(OtherUserProfileScreen.routeName, arguments: userId);
  }

  void _showCommentsBottomSheet(BuildContext context) {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برای ارسال یا مشاهده نظر، ابتدا باید وارد شوید.'),
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
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return CommentsBottomSheetWidget(
              postId: widget.post.id,
              currentUserId: _currentUserId!,
            );
          },
        );
      },
    );
  }

  Widget _buildImageIndicator(int imagesCount, ColorScheme colorScheme) {
    if (imagesCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(imagesCount, (int index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
            _currentImagePage == index
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    String? userAvatarUrl;
    if (widget.post.user.profilePictureRelativeUrl != null &&
        widget.post.user.profilePictureRelativeUrl!.isNotEmpty) {
      userAvatarUrl =
          _apiService.getBaseUrl() +
              widget.post.user.profilePictureRelativeUrl!;
    }

    final imageFiles =
    widget.post.files
        .where((file) => file.mimetype.startsWith('image/'))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title ?? 'جزئیات پست')),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: InkWell(
              onTap: () => _navigateToUserProfile(widget.post.user.id),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                      userAvatarUrl != null
                          ? NetworkImage(userAvatarUrl)
                          : null,
                      child:
                      userAvatarUrl == null
                          ? const Icon(
                        Icons.person_outline_rounded,
                        size: 24,
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.user.displayName ??
                                widget.post.user.email,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            formatDateTime(widget.post.createdAt),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (widget.post.title != null && widget.post.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
              child: Text(
                widget.post.title!,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

          if (imageFiles.isNotEmpty) ...[
            Container(
              color: Colors.black.withOpacity(0.02),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _imagePageController,
                      itemCount: imageFiles.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentImagePage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final file = imageFiles[index];
                        final imageUrl =
                        (file.url.startsWith('http') ||
                            file.url.startsWith('https'))
                            ? file.url
                            : _apiService.getBaseUrl() +
                            (file.url.startsWith('/')
                                ? file.url
                                : '/${file.url}');
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                  ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                    loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        loadingProgress
                                            .expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildImageIndicator(imageFiles.length, colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const SizedBox(height: 8),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MarkdownBody(
              data: widget.post.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.65,
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                strong: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.65,
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                em: textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  height: 1.65,
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                code: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: colorScheme.onSurface.withOpacity(0.05),
                  color: colorScheme.onSurface.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.6,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  border: Border(
                    left: BorderSide(
                      color: colorScheme.primary.withOpacity(0.5),
                      width: 4,
                    ),
                  ),
                ),
                listBullet: textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.65,
                  color: colorScheme.onSurface.withOpacity(0.85),
                ),
                horizontalRuleDecoration: BoxDecoration(
                    border: Border(top: BorderSide(width: 1.0, color: theme.dividerColor))
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon:
                  _isTogglingLike || _isLoadingLikeDetails
                      ? SizedBox(
                    width: 18,
                    height: 18,
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
                    color:
                    isLikedByCurrentUser
                        ? AppTheme.primaryColor
                        : colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    _isLoadingLikeDetails ? "..." : "$likeCount لایک",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed:
                  _isLoadingLikeDetails || _currentUserId == null
                      ? null
                      : _handleLikeButtonTap,
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    Icons.mode_comment_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    "نظرات",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showCommentsBottomSheet(context),
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    "اشتراک",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    final String postTitle =
                        widget.post.title ?? "پست بدون عنوان";
                    final String postContent = widget.post.content;
                    final String shareText =
                        "این پست رو در اپلیکیشن پیوند ببین:\n\n"
                        "عنوان: $postTitle\n"
                        "${postContent.substring(0, postContent.length > 150 ? 150 : postContent.length)}${postContent.length > 150 ? '...' : ''}\n\n"
                        "برای دیدن پست‌های بیشتر، اپلیکیشن پیوند رو نصب کن!";
                    final String subjectText = "پستی از پیوند: $postTitle";
                    Share.share(shareText, subject: subjectText);
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 30,
              thickness: 0.7,
              color: Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: Text(
              'شناسه پست: ${widget.post.id}',
              style: textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}