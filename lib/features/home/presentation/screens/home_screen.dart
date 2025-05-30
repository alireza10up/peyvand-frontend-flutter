import 'package:flutter/material.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/posts/presentation/screens/single_post_screen.dart';
import 'package:peyvand/features/posts/presentation/widgets/post_card_widget.dart';
import 'package:peyvand/features/posts/presentation/screens/create_edit_post_screen.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/profile/presentation/screens/other_user_profile_screen.dart'; //

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPosts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _postService.getAllPosts();
      if (mounted) {
        setState(() {
          _allPosts = posts;
          _filteredPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterPosts() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredPosts = _allPosts;
      });
    } else {
      setState(() {
        _filteredPosts =
            _allPosts.where((post) {
              final titleMatch =
                  post.title?.toLowerCase().contains(query) ?? false;
              final contentMatch = post.content.toLowerCase().contains(query);
              return titleMatch || contentMatch;
            }).toList();
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
      // if (_isSearching) {
      //   FocusScope.of(context).requestFocus(_searchFocusNode);
      // } else {
      //   FocusScope.of(context).unfocus();
      // }
    });
  }

  void _navigateToCreatePost() {
    Navigator.of(context).pushNamed(CreateEditPostScreen.routeName).then((
      value,
    ) {
      _fetchPosts();
      _searchController.clear();
    });
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'جستجو در پست‌ها...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                )
                : const Text('پیوند - فید اصلی'), //
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'بستن جستجو' : 'جستجوی پست‌ها',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: _buildBody(context, colorScheme, textTheme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        //
        onPressed: _navigateToCreatePost,
        label: const Text('پست جدید'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.black87,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
                'خطا در بارگذاری پست‌ها',
                style: textTheme.titleLarge?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش مجدد'),
                onPressed: _fetchPosts,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPosts.isEmpty) {
      //
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.feed_outlined,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty
                    ? 'هنوز پستی برای نمایش وجود ندارد.'
                    : 'هیچ پستی با عبارت جستجو شده یافت نشد.',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'اولین نفری باشید که پست می‌گذارد!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('بارگذاری مجدد'),
                onPressed: _fetchPosts,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return PostCardWidget(
          initialPost: post,
          showStatusChip: false,
          onTapUserProfile: (userId) => _navigateToUserProfile(userId),
          onTapCard: () => _navigateToSinglePost(post),
        );
      },
    );
  }
}
