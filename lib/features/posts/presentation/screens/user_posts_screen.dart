import 'package:flutter/material.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/posts/presentation/screens/create_edit_post_screen.dart';
import 'package:peyvand/features/posts/presentation/widgets/post_card_widget.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart'
    as profile_user_model;
import 'package:peyvand/features/profile/presentation/screens/other_user_profile_screen.dart';
import 'package:peyvand/features/posts/presentation/screens/single_post_screen.dart';

class UserPostsScreen extends StatefulWidget {
  static const String routeName = '/user-posts';

  const UserPostsScreen({super.key});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  List<Post> _userPosts = [];
  bool _isLoadingPosts = true;
  String? _userId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && _userId != null && mounted) {
        _fetchUserPosts();
      }
    });
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _getCurrentUserId();
    if (_userId != null && mounted) {
      _fetchUserPosts();
    }
  }

  Future<void> _getCurrentUserId() async {
    if (!mounted) return;
    try {
      final profile_user_model.User currentUser =
          await _userService.fetchUserProfile();
      if (mounted) {
        setState(() {
          _userId = currentUser.id;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در دریافت اطلاعات کاربر: ${e.toString()}';
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_userId == null || !mounted) return;
    setState(() {
      _isLoadingPosts = true;
      _errorMessage = '';
    });
    try {
      final posts = await _postService.getUserPosts(_userId!);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در بارگذاری پست‌ها: ${e.toString()}';
          _isLoadingPosts = false;
        });
      }
    }
  }

  void _handlePostCardEdit(Post postToEdit) {
    if (mounted) {
      Navigator.of(context)
          .push<bool>(
            MaterialPageRoute(
              builder:
                  (context) => CreateEditPostScreen(
                    post: postToEdit,
                    onPostSaved: () {
                      if (mounted) {
                        _fetchUserPosts();
                      }
                    },
                  ),
            ),
          )
          .then((savedSuccessfully) {
            // if (savedSuccessfully == true && mounted && _userId != null) {
            //   _fetchUserPosts();
            // }
          });
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تایید حذف'),
          content: const Text('آیا از حذف این پست مطمئن هستید؟'),
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
        await _postService.deletePost(postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پست با موفقیت حذف شد.'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchUserPosts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطا در حذف پست: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToSinglePost(Post post) {
    Navigator.of(
      context,
    ).pushNamed(SinglePostScreen.routeName, arguments: post);
  }

  void _navigateToUserProfile(String userId) {
    Navigator.of(
      context,
    ).pushNamed(OtherUserProfileScreen.routeName, arguments: userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت پست‌ها'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'پست‌های من', icon: Icon(Icons.article_outlined)),
            Tab(
              text: 'ایجاد پست',
              icon: Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPostsTab(context),
          CreateEditPostScreen(
            key: UniqueKey(),
            post: null,
            onPostSaved: () {
              if (_userId != null && mounted) {
                _fetchUserPosts();
              }
              _tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyPostsTab(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage.contains("اطلاعات کاربر")
                    ? 'خطا در دریافت اطلاعات کاربری'
                    : 'خطا در بارگذاری پست‌ها',
                style: textTheme.titleLarge?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش مجدد'),
                onPressed: _loadInitialData,
              ),
            ],
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied_outlined,
                size: 60,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'هنوز پستی ارسال نکرده‌اید.',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'از تب "ایجاد پست" اولین پست خود را منتشر کنید!',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('ایجاد اولین پست'),
                onPressed: () {
                  _tabController.animateTo(1);
                },
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          final post = _userPosts[index];
          return PostCardWidget(
            initialPost: post,
            onEdit: () => _handlePostCardEdit(post),
            onDelete: () => _deletePost(post.id),
            showStatusChip: true,
            onTapCard: () => _navigateToSinglePost(post),
            onTapUserProfile: (userId) => _navigateToUserProfile(userId),
          );
        },
      ),
    );
  }
}
