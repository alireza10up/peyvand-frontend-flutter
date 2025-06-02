import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/features/posts/presentation/widgets/post_card_widget.dart';
import 'package:peyvand/features/posts/presentation/screens/single_post_screen.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/connections/data/models/connection_status.dart';
import 'package:peyvand/features/connections/data/models/pending_request_direction.dart';
import 'package:peyvand/features/connections/data/services/connection_service.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'package:peyvand/features/profile/presentation/screens/edit_profile_screen.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart' as intl;
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/features/chat/data/providers/chat_provider.dart';
import 'package:peyvand/features/chat/presentation/screens/individual_chat_screen.dart';
import 'package:peyvand/features/chat/data/models/chat_user_model.dart' as chat_user_model;


class OtherUserProfileScreen extends StatefulWidget {
  static const String routeName = '/other-user-profile';
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final ConnectionService _connectionService = ConnectionService();
  final ApiService _apiService = ApiService();

  User? _user;
  List<Post> _posts = [];
  List<ConnectionInfo> _allGraphConnections = [];
  ConnectionStatus _connectionStatusWithProfileUser = ConnectionStatus.loading;
  PendingRequestDirection _pendingRequestDirection =
      PendingRequestDirection.none;
  int? _apiConnectionIdWithProfileUser;

  bool _isLoadingProfile = true;
  bool _isLoadingPosts = true;
  bool _isLoadingConnectionsForGraph = true;
  bool _isProcessingConnectionAction = false;
  bool _isStartingChat = false;

  String? _currentLoggedInUserId;
  User? _currentUserProfile;
  TabController? _tabController;
  bool _isSelfProfile = false;

  final GlobalKey _graphPaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentLoggedInUserId = authProvider.currentUserId;
    _currentUserProfile = authProvider.currentUser;
    _isSelfProfile = _currentLoggedInUserId == widget.userId;
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  Future<void> _fetchAllData() async {
    setStateIfMounted(() {
      _isLoadingProfile = true;
      _isLoadingPosts = true;
      _isLoadingConnectionsForGraph = true;
      _pendingRequestDirection = PendingRequestDirection.none;
    });
    await _fetchUserProfile();
    if (!_isSelfProfile && _currentLoggedInUserId != null) {
      await _fetchConnectionStatusAndDirectionWithProfileUser();
    } else if (_isSelfProfile) {
      setStateIfMounted(() {
        _connectionStatusWithProfileUser = ConnectionStatus.accepted;
      });
    }
    await _fetchUserPosts();
    await _fetchConnectionsForGraph();
  }

  Future<void> _fetchUserProfile() async {
    setStateIfMounted(() {
      _isLoadingProfile = true;
    });
    try {
      final user = await _userService.fetchUserProfileById(widget.userId);
      setStateIfMounted(() {
        _user = user;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      setStateIfMounted(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchUserPosts() async {
    setStateIfMounted(() {
      _isLoadingPosts = true;
    });
    try {
      final posts = await _postService.getUserPosts(widget.userId);
      setStateIfMounted(() {
        _posts = posts;
      });
    } catch (e) {
    } finally {
      setStateIfMounted(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _fetchConnectionsForGraph() async {
    setStateIfMounted(() {
      _isLoadingConnectionsForGraph = true;
      _allGraphConnections = [];
    });
    try {
      if (_isSelfProfile && _currentLoggedInUserId != null) {
        final accepted = await _connectionService.getAcceptedConnections();
        final sent = await _connectionService.getSentPendingRequests();
        final received = await _connectionService.getReceivedPendingRequests();

        final Map<String, ConnectionInfo> uniqueConnectionsMap = {};
        for (var conn in [...accepted, ...sent, ...received]) {
          uniqueConnectionsMap[conn.user.id] = conn;
        }
        setStateIfMounted(() {
          _allGraphConnections = uniqueConnectionsMap.values.toList();
        });
      } else if (!_isSelfProfile && widget.userId.isNotEmpty) {
        final connections = await _connectionService.getConnectionsForUser(
          widget.userId,
        );
        setStateIfMounted(() {
          _allGraphConnections = connections;
        });
      }
    } catch (e) {
      print("Error fetching connections for graph: $e");
    } finally {
      setStateIfMounted(() {
        _isLoadingConnectionsForGraph = false;
      });
    }
  }

  Future<void> _fetchConnectionStatusAndDirectionWithProfileUser() async {
    if (_isSelfProfile || _currentLoggedInUserId == null) return;
    setStateIfMounted(() {
      _connectionStatusWithProfileUser = ConnectionStatus.loading;
      _isProcessingConnectionAction = true;
      _pendingRequestDirection = PendingRequestDirection.none;
    });
    try {
      final statusResult = await _connectionService.getConnectionStatusWithUser(
        widget.userId,
      );
      _apiConnectionIdWithProfileUser = statusResult['connectionId'];
      ConnectionStatus currentStatus = statusResult['status'];

      if (currentStatus == ConnectionStatus.pending &&
          _apiConnectionIdWithProfileUser != null) {
        bool foundDirection = false;
        try {
          final sentRequests =
          await _connectionService.getSentPendingRequests();
          for (var req in sentRequests) {
            if (req.connectionId == _apiConnectionIdWithProfileUser &&
                req.user.id == widget.userId) {
              _pendingRequestDirection = PendingRequestDirection.sentByMe;
              foundDirection = true;
              break;
            }
          }
        } catch (e) {}

        if (!foundDirection) {
          try {
            final receivedRequests =
            await _connectionService.getReceivedPendingRequests();
            for (var req in receivedRequests) {
              if (req.connectionId == _apiConnectionIdWithProfileUser &&
                  req.user.id == widget.userId) {
                _pendingRequestDirection =
                    PendingRequestDirection.receivedFromProfileUser;
                foundDirection = true;
                break;
              }
            }
          } catch (e) {}
        }
        if (!foundDirection && currentStatus == ConnectionStatus.pending) {
          _pendingRequestDirection = PendingRequestDirection.none;
        }
      }
      setStateIfMounted(() {
        _connectionStatusWithProfileUser = currentStatus;
      });
    } catch (e) {
      setStateIfMounted(() {
        _connectionStatusWithProfileUser = ConnectionStatus.notSend;
      });
    } finally {
      setStateIfMounted(() {
        _isProcessingConnectionAction = false;
      });
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

  Widget _buildProfileHeaderContent(BuildContext context, User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    String? fullProfileImageUrl;
    if (user.profilePictureRelativeUrl != null &&
        user.profilePictureRelativeUrl!.isNotEmpty) {
      fullProfileImageUrl =
          _apiService.getBaseUrl() + user.profilePictureRelativeUrl!;
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
                  backgroundImage:
                  fullProfileImageUrl != null
                      ? NetworkImage(fullProfileImageUrl)
                      : null,
                  child:
                  fullProfileImageUrl == null
                      ? Icon(
                    Icons.person_outline_rounded,
                    size: 60,
                    color: colorScheme.onSurfaceVariant,
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 55),
        Text(
          user.displayName ?? user.email,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (user.email.isNotEmpty)
          Text(
            user.email,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

        if (!_isSelfProfile &&
            _connectionStatusWithProfileUser == ConnectionStatus.pending &&
            _pendingRequestDirection ==
                PendingRequestDirection.receivedFromProfileUser &&
            _apiConnectionIdWithProfileUser != null)
          _buildIncomingRequestBanner(user),

        if (user.bio != null && user.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 24.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 70),
              child: SingleChildScrollView(
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _buildMainActionButtonsRow(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIncomingRequestBanner(User requestingUser) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            '${requestingUser.displayName ?? requestingUser.email} به شما درخواست اتصال داده است.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('قبول'),
                onPressed:
                    () =>
                    _handleAcceptRequest(_apiConnectionIdWithProfileUser!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              OutlinedButton.icon(
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: colorScheme.error,
                ),
                label: Text('رد', style: TextStyle(color: colorScheme.error)),
                onPressed:
                    () =>
                    _handleRejectRequest(_apiConnectionIdWithProfileUser!),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error.withOpacity(0.7)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButtonsRow() {
    final colorScheme = Theme.of(context).colorScheme;

    if ((_isProcessingConnectionAction || _isStartingChat ||
        _connectionStatusWithProfileUser == ConnectionStatus.loading) &&
        !_isSelfProfile) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isSelfProfile && _user != null) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('ویرایش پروفایل من'),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(user: _user!),
            ),
          )
              .then((updated) {
            if (updated == true) _fetchUserProfile();
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (_connectionStatusWithProfileUser == ConnectionStatus.pending &&
        _pendingRequestDirection ==
            PendingRequestDirection.receivedFromProfileUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: OutlinedButton.icon(
          icon: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          label: Text('پیام', style: TextStyle(color: colorScheme.primary)),
          onPressed: _isStartingChat ? null : _handleSendMessage,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 11),
            side: BorderSide(color: colorScheme.primary.withOpacity(0.8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    List<Widget> buttons = [];
    buttons.add(
      Expanded(
        child: OutlinedButton.icon(
          icon: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          label: Text('پیام', style: TextStyle(color: colorScheme.primary)),
          onPressed: _isStartingChat ? null : _handleSendMessage,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 11),
            side: BorderSide(color: colorScheme.primary.withOpacity(0.8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
    buttons.add(const SizedBox(width: 10));

    String connButtonText = _connectionStatusWithProfileUser.displayName;
    VoidCallback? connOnPressedAction;
    IconData connButtonIcon = Icons.person_add_alt_1_outlined;
    ButtonStyle? connButtonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    switch (_connectionStatusWithProfileUser) {
      case ConnectionStatus.notSend:
        connOnPressedAction = _handleSendRequest;
        connButtonStyle = connButtonStyle?.copyWith(
          backgroundColor: MaterialStateProperty.all(AppTheme.primaryColor.withOpacity(0.4)),
        );
        break;
      case ConnectionStatus.pending:
        if (_pendingRequestDirection == PendingRequestDirection.sentByMe) {
          connButtonText = 'لغو درخواست';
          connOnPressedAction = () => _handleCancelRequest(_apiConnectionIdWithProfileUser);
          connButtonIcon = Icons.cancel_outlined;
          connButtonStyle = connButtonStyle?.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.grey.shade300),
          );
        } else {
          // This case (pending but not receivedFromProfileUser and not sentByMe) should ideally not happen often
          // For safety, provide a default or disable
          connButtonText = 'در انتظار';
          connOnPressedAction = null;
          connButtonIcon = Icons.hourglass_empty_rounded;
        }
        break;
      case ConnectionStatus.accepted:
        connButtonText = 'اتصال برقرار';
        connButtonIcon = Icons.how_to_reg_rounded;
        connOnPressedAction = null;
        connButtonStyle = ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer.withOpacity(0.7),
          foregroundColor: colorScheme.onPrimaryContainer,
          elevation: 0,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
        break;
      case ConnectionStatus.blocked:
        connButtonText = 'رفع انسداد';
        connOnPressedAction = _handleUnblockUser;
        connButtonIcon = Icons.lock_open_outlined;
        connButtonStyle = connButtonStyle?.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.orange.shade800),
        );
        break;
      case ConnectionStatus.loading:
        connButtonText = 'کمی صبر...';
        connOnPressedAction = null;
        break;
      default:
        connOnPressedAction = _handleSendRequest;
        connButtonStyle = connButtonStyle?.copyWith(
          backgroundColor: MaterialStateProperty.all(AppTheme.accentColor),
        );
    }

    buttons.add(
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(connButtonIcon, size: 18),
          label: Text(connButtonText),
          onPressed: connOnPressedAction,
          style: connButtonStyle,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      ),
    );
  }

  Future<void> _handleSendMessage() async {
    if (_user == null || _currentUserProfile == null || _isStartingChat) return;

    setStateIfMounted(() {
      _isStartingChat = true;
    });

    try {
      final chatProvider = ChatProvider(_currentUserProfile!.id, _currentUserProfile!);
      final conversation = await chatProvider.createOrGetConversationWithUser(int.parse(_user!.id));

      if (conversation != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IndividualChatScreen(
              conversationId: conversation.id,
              otherParticipant: chat_user_model.ChatUserModel.fromProfileUser(_user!),
              chatProvider: chatProvider,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ایجاد یا دریافت گفتگو.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در شروع چت: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setStateIfMounted(() {
          _isStartingChat = false;
        });
      }
    }
  }

  Future<void> _performConnectionAction(Future<void> Function() action) async {
    if (_isProcessingConnectionAction) return;
    setStateIfMounted(() {
      _isProcessingConnectionAction = true;
    });
    try {
      await action();
      await _fetchConnectionStatusAndDirectionWithProfileUser();
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is ApiException) {
          errorMessage = e.combinedMessage;
          if (e.statusCode == 403) {
            errorMessage = "شما مجاز به انجام این عملیات نیستید.";
          } else if (e.statusCode == 404) {
            errorMessage = "درخواست مورد نظر یافت نشد یا دیگر معتبر نیست.";
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      await _fetchConnectionStatusAndDirectionWithProfileUser();
    } finally {
      setStateIfMounted(() {
        _isProcessingConnectionAction = false;
      });
    }
  }

  void _handleSendRequest() => _performConnectionAction(
        () => _connectionService.sendConnectionRequest(widget.userId),
  );

  void _handleCancelRequest(int? connectionId) {
    if (connectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا: شناسه درخواست نامعتبر.')),
      );
      _fetchConnectionStatusAndDirectionWithProfileUser();
      return;
    }
    _performConnectionAction(
          () => _connectionService.cancelSentRequest(connectionId),
    );
  }

  void _handleAcceptRequest(int connectionId) => _performConnectionAction(
        () => _connectionService.acceptReceivedRequest(connectionId),
  );

  void _handleRejectRequest(int connectionId) => _performConnectionAction(
        () => _connectionService.rejectReceivedRequest(connectionId),
  );

  void _handleBlockUser() => _performConnectionActionWithConfirmation(
    title: 'بلاک کردن کاربر',
    content:
    'آیا از بلاک کردن این کاربر (${_user?.displayName ?? ""}) مطمئن هستید؟',
    action: () => _connectionService.blockUser(widget.userId),
  );

  void _handleUnblockUser() => _performConnectionAction(
        () => _connectionService.unblockUser(widget.userId),
  );

  void _handleDeleteConnection() {
    if (_apiConnectionIdWithProfileUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان حذف اتصال وجود ندارد.')),
      );
      return;
    }
    _performConnectionActionWithConfirmation(
      title: 'حذف اتصال',
      content:
      'آیا از حذف اتصال با ${_user?.displayName ?? "این کاربر"} مطمئن هستید؟',
      action:
          () => _connectionService.deleteConnection(
        _apiConnectionIdWithProfileUser!,
      ),
    );
  }

  Future<void> _performConnectionActionWithConfirmation({
    required String title,
    required String content,
    required Future<void> Function() action,
  }) async {
    if (_isProcessingConnectionAction) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'تایید',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _performConnectionAction(action);
  }

  Widget _buildInfoTile(
      BuildContext context,
      IconData icon,
      String title,
      String? value,
      ) {
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
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems() {
    List<PopupMenuEntry<String>> items = [];
    if (_isSelfProfile) return items;

    if (_connectionStatusWithProfileUser == ConnectionStatus.accepted &&
        _apiConnectionIdWithProfileUser != null) {
      items.add(
        PopupMenuItem<String>(
          value: 'delete_connection',
          child: ListTile(
            leading: Icon(
              Icons.person_remove_outlined,
              color: Colors.orange.shade700,
              size: 20,
            ),
            title: const Text('حذف اتصال', style: TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    if (_connectionStatusWithProfileUser != ConnectionStatus.blocked) {
      items.add(
        PopupMenuItem<String>(
          value: 'block_user',
          child: ListTile(
            leading: Icon(
              Icons.block_flipped,
              color: Colors.red.shade700,
              size: 20,
            ),
            title: const Text('بلاک کردن', style: TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    if (items.isNotEmpty) items.add(const PopupMenuDivider());
    items.add(
      const PopupMenuItem<String>(
        value: 'report_user',
        child: ListTile(
          leading: Icon(Icons.report_gmailerrorred_rounded, size: 20),
          title: Text('گزارش کاربر', style: TextStyle(fontSize: 14)),
        ),
      ),
    );
    return items;
  }

  void _onPopupMenuItemSelected(String value) {
    switch (value) {
      case 'delete_connection':
        _handleDeleteConnection();
        break;
      case 'block_user':
        _handleBlockUser();
        break;
      case 'report_user':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('قابلیت گزارش کاربر به زودی اضافه خواهد شد.'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final popupMenuItems = _buildPopupMenuItems();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body:
      _isLoadingProfile || _user == null
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
        headerSliverBuilder: (
            BuildContext context,
            bool innerBoxIsScrolled,
            ) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 430.0,
              floating: false,
              pinned: true,
              elevation: 0.5,
              backgroundColor:
              Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor:
              Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (!_isSelfProfile && popupMenuItems.isNotEmpty)
                  PopupMenuButton<String>(
                    onSelected: _onPopupMenuItemSelected,
                    itemBuilder:
                        (BuildContext context) => popupMenuItems,
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.15),
                        colorScheme.primary.withOpacity(0.01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: _buildProfileHeaderContent(context, _user!),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(
                      context,
                      Icons.confirmation_number_outlined,
                      'کد دانشجویی',
                      _user!.studentCode,
                    ),
                    _buildInfoTile(
                      context,
                      Icons.school_outlined,
                      'دانشگاه',
                      _user!.university,
                    ),
                    _buildInfoTile(
                      context,
                      Icons.lightbulb_outline_rounded,
                      'مهارت‌ها',
                      _user!.skills?.join('، '),
                    ),
                    // _buildInfoTile(
                    //   context,
                    //   Icons.cake_outlined,
                    //   'تاریخ تولد',
                    //   formatBirthDate(_user!.birthDate),
                    // ),
                    _buildInfoTile(
                      context,
                      Icons.date_range_outlined,
                      'عضو از',
                      formatDisplayDate(_user!.createdAtDate),
                    ),
                  ],
                ),
              ),
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
                    Tab(
                      child: Text(
                        'پست‌ها',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'ارتباطات',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildPostsTab(), _buildConnectionsTab()],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isLoadingPosts)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    if (_posts.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('این کاربر هنوز پستی منتشر نکرده است.'),
        ),
      );

    return RefreshIndicator(
      onRefresh: _fetchUserPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 8.0,
          right: 8.0,
          bottom: 16.0,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCardWidget(
            initialPost: post,
            showStatusChip: _isSelfProfile,
            onTapCard:
                () => Navigator.of(
              context,
            ).pushNamed(SinglePostScreen.routeName, arguments: post),
            onTapUserProfile: (userId) {
              if (userId != widget.userId) {
                Navigator.of(context).pushReplacementNamed(
                  OtherUserProfileScreen.routeName,
                  arguments: userId,
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildConnectionsTab() {
    final textTheme = Theme.of(context).textTheme;
    if (_isLoadingConnectionsForGraph)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );

    if (_allGraphConnections.isEmpty && _user != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _isSelfProfile
                ? 'هنوز ارتباطی ثبت نکرده‌اید.'
                : 'این کاربر هنوز دوستی ندارد.',
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }
    if (_user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 8.0,
        right: 8.0,
        bottom: 16.0,
      ),
      child: Column(
        children: [
          if (_allGraphConnections.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allGraphConnections.length,
              itemBuilder: (context, index) {
                final conn = _allGraphConnections[index];
                String? avatarUrl;
                if (conn.user.profilePictureRelativeUrl != null &&
                    conn.user.profilePictureRelativeUrl!.isNotEmpty) {
                  avatarUrl =
                      _apiService.getBaseUrl() +
                          conn.user.profilePictureRelativeUrl!;
                }

                IconData statusIcon = Icons.link_rounded;
                Color statusColor = AppTheme.primaryColor;
                String statusText = "دوست";

                if (_isSelfProfile) {
                  switch (conn.status) {
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
                    default: // accepted
                      statusIcon = Icons.how_to_reg_rounded;
                      statusColor = Colors.green.shade700;
                      statusText = "دوست";
                  }
                }

                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child:
                      avatarUrl == null
                          ? const Icon(
                        Icons.person_outline_rounded,
                        size: 22,
                      )
                          : null,
                    ),
                    title: Text(
                      conn.user.displayName ?? conn.user.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      _isSelfProfile
                          ? statusText
                          : (conn.user.university ??
                          'اطلاعات دانشگاه موجود نیست'),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        _isSelfProfile ? statusColor : Colors.grey.shade600,
                      ),
                    ),
                    trailing:
                    _isSelfProfile
                        ? Icon(statusIcon, color: statusColor, size: 20)
                        : Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    onTap: () {
                      if (conn.user.id != _currentLoggedInUserId) {
                        Navigator.of(context).pushNamed(
                          OtherUserProfileScreen.routeName,
                          arguments: conn.user.id,
                        );
                      }
                    },
                  ),
                );
              },
            ),
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

    List<ConnectionInfo> connectionsForPainter =
    _isSelfProfile
        ? _allGraphConnections
        : _allGraphConnections
        .where((c) => c.status == ConnectionStatus.accepted)
        .toList();

    return Column(
      children: [
        Text(
          _isSelfProfile
              ? "شبکه ارتباطات شما"
              : "دوستان ${_user!.firstName ?? ''}",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            if (_graphPaintKey.currentContext != null) {
              final RenderBox renderBox =
              _graphPaintKey.currentContext!.findRenderObject()
              as RenderBox;
            }
          },
          child: Container(
            key: _graphPaintKey,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.all(16),
            height: 280,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _SimpleConnectionGraphPainter(
                centerUser: _user!,
                connections: connectionsForPainter,
                primaryColor: AppTheme.primaryColor,
                accentColor: AppTheme.accentColor,
                pendingSentColor: Colors.orange.shade700,
                pendingReceivedColor: Colors.green.shade700,
                onNodeTap: (tappedUserId) {
                  if (tappedUserId != _currentLoggedInUserId &&
                      tappedUserId != _user?.id) {
                    Navigator.of(context).pushNamed(
                      OtherUserProfileScreen.routeName,
                      arguments: tappedUserId,
                    );
                  }
                },
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
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
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
    final double graphRadius =
        (size.width < size.height ? size.width : size.height) /
            3.0;
    final double centerNodeRadius = 28.0;
    final double connectionNodeRadius = 22.0;
    final double labelOffset = 12.0;

    final centerNodeRect = Rect.fromCircle(
      center: center,
      radius: centerNodeRadius,
    );
    _nodeTapRegions[centerNodeRect] = centerUser.id;
    canvas.drawCircle(center, centerNodeRadius, centerNodePaint);
    _drawText(
      canvas,
      centerUser.firstName?.substring(0, 1).toUpperCase() ?? "U",
      center,
      centerNodeRadius - 9,
      Colors.white,
    );
    _drawNodeLabel(
      canvas,
      centerUser.displayName ?? centerUser.email,
      center,
      centerNodeRadius + labelOffset,
      size,
      primaryColor,
      isCenter: true,
    );

    if (connections.isEmpty) return;

    final int maxDisplayConnections = 5;
    final List<ConnectionInfo> displayConnections =
    connections.take(maxDisplayConnections).toList();
    final angleStep =
        (2 * math.pi) /
            (displayConnections.length > 0 ? displayConnections.length : 1);

    for (int i = 0; i < displayConnections.length; i++) {
      final ConnectionInfo connInfo = displayConnections[i];
      final User nodeUser = connInfo.user;
      final double currentAngle = angleStep * i - (math.pi / 2);
      final Offset nodeCenter = Offset(
        center.dx + graphRadius * math.cos(currentAngle),
        center.dy + graphRadius * math.sin(currentAngle),
      );

      switch (connInfo.status) {
        case ConnectionStatus.pending:
          linePaint.color = pendingSentColor.withOpacity(0.06);
          nodePaint.color = pendingSentColor;
          break;
        case ConnectionStatus.accepted:
          linePaint.color = primaryColor.withOpacity(0.35);
          nodePaint.color = accentColor;
          break;
        default:
          linePaint.color = Colors.grey.withOpacity(0.03);
          nodePaint.color = Colors.grey;
      }

      canvas.drawLine(center, nodeCenter, linePaint);

      final connectionNodeRect = Rect.fromCircle(
        center: nodeCenter,
        radius: connectionNodeRadius,
      );
      _nodeTapRegions[connectionNodeRect] = nodeUser.id;
      canvas.drawCircle(nodeCenter, connectionNodeRadius, nodePaint);
      _drawText(
        canvas,
        nodeUser.firstName?.substring(0, 1).toUpperCase() ?? "?",
        nodeCenter,
        connectionNodeRadius - 7,
        Colors.black87,
      );
      _drawNodeLabel(
        canvas,
        nodeUser.displayName ?? nodeUser.email,
        nodeCenter,
        connectionNodeRadius + labelOffset,
        size,
        nodePaint.color.withAlpha(255),
      );
    }
  }

  void _drawNodeLabel(
      Canvas canvas,
      String text,
      Offset nodeCenter,
      double offsetFromNode,
      Size canvasSize,
      Color textColor, {
        bool isCenter = false,
      }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: isCenter ? 11 : 10,
          fontFamily: 'Vazir',
          fontWeight: isCenter ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: isCenter ? 80 : 65);

    Offset labelPosition = Offset(
      nodeCenter.dx - textPainter.width / 2,
      nodeCenter.dy + offsetFromNode,
    );

    if (labelPosition.dx < 0) labelPosition = Offset(2, labelPosition.dy);
    if (labelPosition.dx + textPainter.width > canvasSize.width) {
      labelPosition = Offset(
        canvasSize.width - textPainter.width - 2,
        labelPosition.dy,
      );
    }
    if (labelPosition.dy + textPainter.height > canvasSize.height) {
      labelPosition = Offset(
        labelPosition.dx,
        canvasSize.height - textPainter.height - 2,
      );
    }
    if (labelPosition.dy < 0 && !isCenter) {
      labelPosition = Offset(
        labelPosition.dx,
        nodeCenter.dy - offsetFromNode - textPainter.height,
      );
    }

    textPainter.paint(canvas, labelPosition);
  }

  void _drawText(
      Canvas canvas,
      String text,
      Offset position,
      double size,
      Color color,
      ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
          fontFamily: 'Vazir',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SimpleConnectionGraphPainter oldDelegate) =>
      oldDelegate.centerUser != centerUser ||
          oldDelegate.connections != connections ||
          oldDelegate.onNodeTap != onNodeTap;

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