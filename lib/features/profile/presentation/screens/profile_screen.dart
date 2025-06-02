import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/posts/presentation/widgets/post_card_widget.dart';
import 'package:peyvand/features/posts/presentation/screens/single_post_screen.dart';
import 'package:peyvand/features/posts/presentation/screens/create_edit_post_screen.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/features/connections/data/models/connection_status.dart';
import 'package:peyvand/features/connections/data/services/connection_service.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'package:peyvand/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:peyvand/features/auth/presentation/screens/auth_screen.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart' as intl;

import 'package:peyvand/features/auth/data/services/auth_service.dart';
import 'other_user_profile_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final PostService _postService = PostService();
  final ConnectionService _connectionService = ConnectionService();

  User? _user;
  List<Post> _myPosts = [];
  List<ConnectionInfo> _myGraphConnections = [];

  bool _isLoadingProfile = true;
  bool _isLoadingPosts = true;
  bool _isLoadingConnections = true;

  TabController? _tabController;
  final GlobalKey _graphPaintKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllMyData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  Future<void> _fetchAllMyData() async {
    setStateIfMounted(() {
      _isLoadingProfile = true;
      _isLoadingPosts = true;
      _isLoadingConnections = true;
    });
    await _loadUserProfile();
    if (_user != null) {
      await _loadMyPosts();
      await _loadMyConnectionsForGraph();
    }
  }

  Future<void> _loadUserProfile() async {
    setStateIfMounted(() { _isLoadingProfile = true; });
    try {
      final user = await _userService.fetchUserProfile();
      setStateIfMounted(() { _user = user; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در دریافت اطلاعات پروفایل: ${e.toString()}')),
        );
      }
    } finally {
      setStateIfMounted(() { _isLoadingProfile = false; });
    }
  }

  Future<void> _loadMyPosts() async {
    if (_user == null) return;
    setStateIfMounted(() { _isLoadingPosts = true; });
    try {
      final posts = await _postService.getUserPosts(_user!.id);
      setStateIfMounted(() { _myPosts = posts;});
    } catch (e) {/* خطا */} finally {
      setStateIfMounted(() { _isLoadingPosts = false; });
    }
  }

  Future<void> _loadMyConnectionsForGraph() async {
    if (_user == null) return;
    setStateIfMounted(() { _isLoadingConnections = true; _myGraphConnections = []; });
    try {
      final accepted = await _connectionService.getAcceptedConnections();
      final sent = await _connectionService.getSentPendingRequests();
      final received = await _connectionService.getReceivedPendingRequests();

      final Map<String, ConnectionInfo> uniqueConnectionsMap = {};
      for (var conn in [...accepted, ...received, ...sent]) {
        if (!uniqueConnectionsMap.containsKey(conn.user.id)) {
          uniqueConnectionsMap[conn.user.id] = conn;
        } else if (conn.status == ConnectionStatus.accepted) {
          uniqueConnectionsMap[conn.user.id] = conn;
        }
      }
      setStateIfMounted(() { _myGraphConnections = uniqueConnectionsMap.values.toList(); });
    } catch (e) {
      print("Error fetching my connections for graph: $e");
    } finally {
      setStateIfMounted(() { _isLoadingConnections = false; });
    }
  }

  Future<void> _handleEditPost(Post post) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateEditPostScreen(post: post),
      ),
    );
    if (result == true && mounted) {
      _loadMyPosts();
    }
  }

  Future<void> _handleDeletePost(int postId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تایید حذف پست'),
          content: const Text('آیا از حذف این پست مطمئن هستید؟ این عمل قابل بازگشت نیست.'),
          actions: <Widget>[
            TextButton(child: const Text('لغو'), onPressed: () => Navigator.of(context).pop(false)),
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
        setStateIfMounted(() { _isLoadingPosts = true; });
        await _postService.deletePost(postId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پست با موفقیت حذف شد.'), backgroundColor: Colors.green),
        );
        _loadMyPosts(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف پست: ${e.toString()}')),
        );
      } finally {
        setStateIfMounted(() { _isLoadingPosts = false; });
      }
    }
  }


  String formatDisplayDate(DateTime? dateTime) {
    if (dateTime == null) return 'نامشخص';
    final formatter = intl.DateFormat('d MMMM yy', 'fa_IR');
    return formatter.format(dateTime.toLocal());
  }

  String formatBirthDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'ثبت نشده';
    DateTime? parsedDate = DateTime.tryParse(dateString);
    if (parsedDate == null) return dateString;
    return formatDisplayDate(parsedDate);
  }

  Widget _buildMyProfileHeaderContent(BuildContext context, User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String? fullProfileImageUrl;
    if (user.profilePictureRelativeUrl != null && user.profilePictureRelativeUrl!.isNotEmpty) {
      fullProfileImageUrl = _apiService.getBaseUrl() + user.profilePictureRelativeUrl!;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(height: 160),
            Positioned(
              bottom: -50,
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 52,
                  backgroundImage: fullProfileImageUrl != null ? NetworkImage(fullProfileImageUrl) : null,
                  child: fullProfileImageUrl == null
                      ? Icon(Icons.person_outline_rounded, size: 60, color: colorScheme.onSurfaceVariant)
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 55),
        Text(user.displayName ?? user.email, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        if (user.email.isNotEmpty) Text(user.email, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        if (user.bio != null && user.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 70),
                child: SingleChildScrollView(
                  child: Text(user.bio!, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(height: 1.4)),
                )
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('ویرایش پروفایل'),
          onPressed: () async {
            if (_user == null) return;
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(user: _user!),
              ),
            );
            if (result == true && mounted) {
              _loadUserProfile();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String? value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0.2,
      color: colorScheme.surface.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _isLoadingProfile || _user == null
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 420.0,
              floating: false,
              pinned: true,
              elevation: 0.5,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text("پروفایل من", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: _logout,
                  tooltip: 'خروج از حساب',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary.withOpacity(0.15), colorScheme.primary.withOpacity(0.01)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                  ),
                  child: _buildMyProfileHeaderContent(context, _user!),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile(context, Icons.confirmation_number_outlined, 'کد دانشجویی', _user!.studentCode),
                      _buildInfoTile(context, Icons.school_outlined, 'دانشگاه', _user!.university),
                      _buildInfoTile(context, Icons.lightbulb_outline_rounded, 'مهارت‌ها', _user!.skills?.join('، ')),
                      // _buildInfoTile(context, Icons.cake_outlined, 'تاریخ تولد', formatBirthDate(_user!.birthDate)),
                      _buildInfoTile(context, Icons.date_range_outlined, 'عضو از', formatDisplayDate(_user!.createdAtDate)),
                    ],
                  ),
                )
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 2.5,
                  tabs: const [
                    Tab(child: Text('پست‌های من', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
                    Tab(child: Text('ارتباطات من', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyPostsTab(),
            _buildMyConnectionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPostsTab() {
    if (_isLoadingPosts) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child:CircularProgressIndicator()));
    if (_myPosts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0),child: Text('هنوز پستی منتشر نکرده‌اید.')));

    return RefreshIndicator(
      onRefresh: _loadMyPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0, bottom: 16.0),
        itemCount: _myPosts.length,
        itemBuilder: (context, index) {
          final post = _myPosts[index];
          return PostCardWidget(
            initialPost: post,
            showStatusChip: true,
            onTapCard: () => Navigator.of(context).pushNamed(SinglePostScreen.routeName, arguments: post),
            onEdit: () => _handleEditPost(post),
            onDelete: () => _handleDeletePost(post.id),
            onTapUserProfile: (userId) {
            },
          );
        },
      ),
    );
  }

  Widget _buildMyConnectionsTab() {
    final textTheme = Theme.of(context).textTheme;
    if (_isLoadingConnections) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child:CircularProgressIndicator()));

    if (_myGraphConnections.isEmpty && _user != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0),child: Text('هنوز ارتباطی ثبت نکرده‌اید.', style: textTheme.bodyMedium)));
    }
    if (_user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0, bottom: 16.0),
      child: Column(
        children: [
          if (_myGraphConnections.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myGraphConnections.length,
              itemBuilder: (context, index) {
                final conn = _myGraphConnections[index];
                String? avatarUrl;
                if (conn.user.profilePictureRelativeUrl != null && conn.user.profilePictureRelativeUrl!.isNotEmpty) {
                  avatarUrl = _apiService.getBaseUrl() + conn.user.profilePictureRelativeUrl!;
                }

                IconData statusIcon = Icons.link_rounded;
                Color statusColor = AppTheme.primaryColor;
                String statusText = "ارتباط";

                switch(conn.status) {
                  case ConnectionStatus.pending:
                    statusIcon = Icons.hourglass_empty_rounded;
                    statusColor = Colors.orange.shade700;
                    statusText = "در انتظار تایید";
                    break;
                  case ConnectionStatus.blocked:
                    statusIcon = Icons.block_flipped;
                    statusColor = Colors.red.shade700;
                    statusText = "بلاک شده";
                    break;
                  case ConnectionStatus.accepted:
                    statusIcon = Icons.how_to_reg_rounded;
                    statusColor = Colors.green.shade700;
                    statusText = "دوست";
                    break;
                  default:
                    statusIcon = Icons.help_outline_rounded;
                    statusColor = Colors.grey;
                    statusText = conn.status.name;
                }

                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null ? const Icon(Icons.person_outline_rounded, size: 22) : null,
                    ),
                    title: Text(conn.user.displayName ?? conn.user.email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(statusText, style: TextStyle(fontSize: 13, color: statusColor)),
                    trailing: Icon(statusIcon, color: statusColor, size: 20),
                    onTap: () {
                      Navigator.of(context).pushNamed(OtherUserProfileScreen.routeName, arguments: conn.user.id);
                    },
                  ),
                );
              },
            ),
          if (_user != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: _buildConnectionGraphWidget(),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionGraphWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text("شبکه ارتباطات شما", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            if (_graphPaintKey.currentContext != null) {
              final RenderBox renderBox = _graphPaintKey.currentContext!.findRenderObject() as RenderBox;
              final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
            }
          },
          child: Container(
            key: _graphPaintKey,
            margin: const EdgeInsets.only(top: 10, bottom:10),
            padding: const EdgeInsets.all(16),
            height: 280,
            decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0,2)
                  )
                ]
            ),
            child: CustomPaint(
              painter: _SimpleConnectionGraphPainter(
                  centerUser: _user!,
                  connections: _myGraphConnections,
                  primaryColor: AppTheme.primaryColor,
                  accentColor: AppTheme.accentColor,
                  pendingSentColor: Colors.orange.shade700,
                  pendingReceivedColor: Colors.lightGreen.shade700,
                  onNodeTap: (tappedUserId) {
                    Navigator.of(context).pushNamed(OtherUserProfileScreen.routeName, arguments: tappedUserId);
                  }
              ),
              child: const Center(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.8))
      ),
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _SimpleConnectionGraphPainter extends CustomPainter {
  final User centerUser;
  final List<ConnectionInfo> connections;
  final Color primaryColor;
  final Color accentColor;
  final Color pendingSentColor;
  final Color pendingReceivedColor;
  final Function(String userId)? onNodeTap;

  final Map<Rect, String> _nodeTapRegions = {};

  _SimpleConnectionGraphPainter({
    required this.centerUser,
    required this.connections,
    required this.primaryColor,
    required this.accentColor,
    required this.pendingSentColor,
    required this.pendingReceivedColor,
    this.onNodeTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _nodeTapRegions.clear();
    final Paint linePaint = Paint()..strokeWidth = 1.3;
    final Paint nodePaint = Paint();
    final Paint centerNodePaint = Paint()..color = primaryColor;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double graphRadius = (size.width < size.height ? size.width : size.height) / 3.0;
    final double centerNodeRadius = 28.0;
    final double connectionNodeRadius = 22.0;
    final double labelOffset = 12.0;

    final centerNodeRect = Rect.fromCircle(center: center, radius: centerNodeRadius);
    canvas.drawCircle(center, centerNodeRadius, centerNodePaint);
    _drawText(canvas, centerUser.firstName?.substring(0,1).toUpperCase() ?? "U", center, centerNodeRadius - 9, Colors.white);
    _drawNodeLabel(canvas, centerUser.displayName ?? centerUser.email , center, centerNodeRadius + labelOffset, size, primaryColor, isCenter: true);


    if (connections.isEmpty) return;

    final int maxDisplayConnections = 5;
    final List<ConnectionInfo> displayConnections = connections.take(maxDisplayConnections).toList();
    final angleStep = (2 * math.pi) / (displayConnections.length > 0 ? displayConnections.length : 1);

    for (int i = 0; i < displayConnections.length; i++) {
      final ConnectionInfo connInfo = displayConnections[i];
      final User nodeUser = connInfo.user;
      final double currentAngle = angleStep * i - (math.pi / 2);
      final Offset nodeCenter = Offset(
        center.dx + graphRadius * math.cos(currentAngle),
        center.dy + graphRadius * math.sin(currentAngle),
      );

      Color currentLineColor = primaryColor.withOpacity(0.35);
      Color currentNodeColor = accentColor;

      switch(connInfo.status) {
        case ConnectionStatus.pending:
          currentLineColor = pendingSentColor.withOpacity(0.6);
          currentNodeColor = pendingSentColor;
          break;
        case ConnectionStatus.accepted:
          currentLineColor = primaryColor.withOpacity(0.35);
          currentNodeColor = accentColor;
          break;
        default: // blocked, not_send, etc.
          currentLineColor = Colors.grey.withOpacity(0.3);
          currentNodeColor = Colors.grey;
      }

      linePaint.color = currentLineColor;
      nodePaint.color = currentNodeColor;

      canvas.drawLine(center, nodeCenter, linePaint);

      final connectionNodeRect = Rect.fromCircle(center: nodeCenter, radius: connectionNodeRadius);
      _nodeTapRegions[connectionNodeRect] = nodeUser.id;
      canvas.drawCircle(nodeCenter, connectionNodeRadius, nodePaint);
      _drawText(canvas, nodeUser.firstName?.substring(0,1).toUpperCase() ?? "?", nodeCenter, connectionNodeRadius - 7, Colors.black87);
      _drawNodeLabel(canvas, nodeUser.displayName ?? nodeUser.email, nodeCenter, connectionNodeRadius + labelOffset, size, nodePaint.color.withBlue(nodePaint.color.blue - 20).withAlpha(255));
    }
  }

  void _drawNodeLabel(Canvas canvas, String text, Offset nodeCenter, double offsetFromNode, Size canvasSize, Color textColor, {bool isCenter = false}) {
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: textColor, fontSize: isCenter ? 11 : 10, fontFamily: 'Vazir', fontWeight: isCenter ? FontWeight.w600 : FontWeight.w500)),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '...'
    );
    textPainter.layout(maxWidth: isCenter ? 80 : 65);

    Offset labelPosition = Offset(nodeCenter.dx - textPainter.width / 2, nodeCenter.dy + offsetFromNode);

    if (labelPosition.dx < 0) labelPosition = Offset(2, labelPosition.dy);
    if (labelPosition.dx + textPainter.width > canvasSize.width) labelPosition = Offset(canvasSize.width - textPainter.width - 2, labelPosition.dy);
    if (labelPosition.dy + textPainter.height > canvasSize.height) labelPosition = Offset(labelPosition.dx, canvasSize.height - textPainter.height -2);
    if (labelPosition.dy < 0 && !isCenter) labelPosition = Offset(labelPosition.dx, nodeCenter.dy - offsetFromNode - textPainter.height);


    textPainter.paint(canvas, labelPosition);
  }

  void _drawText(Canvas canvas, String text, Offset position, double size, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SimpleConnectionGraphPainter oldDelegate) =>
      oldDelegate.centerUser != centerUser || oldDelegate.connections != connections || oldDelegate.onNodeTap != onNodeTap;

  @override
  bool? hitTest(Offset position) {
    for (var entry in _nodeTapRegions.entries) {
      if (entry.key.contains(position)) {
        if (entry.value != centerUser.id && onNodeTap != null) {
          onNodeTap!(entry.value);
        }
        return true;
      }
    }
    return false;
  }
}