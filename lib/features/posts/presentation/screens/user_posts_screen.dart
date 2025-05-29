import 'package:flutter/material.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/posts/presentation/screens/create_edit_post_screen.dart';
import 'package:peyvand/features/posts/presentation/widgets/post_card_widget.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart'
    as profile_user_model;
import 'package:peyvand/services/api_service.dart';

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
  final ApiService _apiService = ApiService();

  List<Post> _userPosts = [];
  bool _isLoadingPosts = true;
  String? _userId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && _userId != null) {
        _fetchUserPosts();
      }
    });
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _getCurrentUserId();
    if (_userId != null) {
      _fetchUserPosts();
    }
  }

  Future<void> _getCurrentUserId() async {
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
          _errorMessage = 'خطا در دریافت اطلاعات کاربر: $e';
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_userId == null) return;
    if (!mounted) return;
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
          _errorMessage = 'خطا در بارگذاری پست‌ها: $e';
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
                      if (mounted && _userId != null) {
                        _fetchUserPosts();
                      }
                    },
                  ),
            ),
          )
          .then((result) {
            if (result == true && mounted && _userId != null) {
              _fetchUserPosts();
            }
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

    if (confirmDelete == true) {
      try {
        await _postService.deletePost(postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پست با موفقیت حذف شد.'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchUserPosts(); // رفرش لیست
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطا در حذف پست: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          _buildMyPostsTab(),
          CreateEditPostScreen(
            key: UniqueKey(),
            post: null,
            onPostSaved: () {
              if (_userId != null) {
                _fetchUserPosts();
              }
              _tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
    //   floatingActionButton:
    //       _tabController.index ==
    //               0
    //           ? FloatingActionButton.extended(
    //             onPressed: () {
    //               _tabController.animateTo(1);
    //               _navigateToCreateEditPostScreen();
    //             },
    //             label: const Text('پست جدید'),
    //             icon: const Icon(Icons.add_rounded),
    //             backgroundColor: colorScheme.primary,
    //             foregroundColor: colorScheme.onPrimary,
    //           )
    //           : null,
    // );
  }

  Widget _buildMyPostsTab() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty && _userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }
    if (_userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'هنوز پستی ارسال نکرده‌اید.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('بارگذاری مجدد'),
              onPressed: _fetchUserPosts,
            ),
          ],
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
            post: post,
            onEdit: () => _handlePostCardEdit(post),
            onDelete: () => _deletePost(post.id),
          );
        },
      ),
    );
  }
}
