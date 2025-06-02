import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/presentation/screens/other_user_profile_screen.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/connections/data/models/connection_status.dart';
import 'package:peyvand/features/connections/data/models/pending_request_direction.dart';
import 'package:peyvand/features/connections/data/services/connection_service.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen>
    with SingleTickerProviderStateMixin {
  final ConnectionService _connectionService = ConnectionService();
  final ApiService _apiService = ApiService();

  User? _currentUser;
  List<ConnectionInfo> _allConnectionsForGraph = [];
  List<ConnectionInfo> _receivedPendingRequests = [];

  bool _isLoading = true;
  String? _error;
  TabController? _tabController;

  final GlobalKey _graphKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNetworkData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadNetworkData() async {
    setStateIfMounted(() {
      _isLoading = true;
      _error = null;
      _allConnectionsForGraph = [];
      _receivedPendingRequests = [];
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentUser = authProvider.currentUser;

      if (_currentUser == null) {
        throw ApiException(messages: ['کاربر لاگین نکرده است.']);
      }

      final acceptedFuture = _connectionService.getAcceptedConnections();
      final sentFuture = _connectionService.getSentPendingRequests();
      final receivedFuture = _connectionService.getReceivedPendingRequests();

      final results = await Future.wait([
        acceptedFuture,
        sentFuture,
        receivedFuture,
      ]);

      final List<ConnectionInfo> accepted = results[0] as List<ConnectionInfo>;
      final List<ConnectionInfo> sent = results[1] as List<ConnectionInfo>;
      final List<ConnectionInfo> received = results[2] as List<ConnectionInfo>;

      final Map<String, ConnectionInfo> uniqueConnectionsMap = {};

      for (var conn in accepted) {
        if (!uniqueConnectionsMap.containsKey(conn.user.id)) {
          uniqueConnectionsMap[conn.user.id] = conn.copyWith(
            pendingDir: PendingRequestDirection.none,
          );
        }
      }
      for (var conn in sent) {
        if (!uniqueConnectionsMap.containsKey(conn.user.id)) {
          uniqueConnectionsMap[conn.user.id] = conn.copyWith(
            pendingDir: PendingRequestDirection.sentByMe,
          );
        }
      }
      for (var conn in received) {
        _receivedPendingRequests.add(
          conn.copyWith(
            pendingDir: PendingRequestDirection.receivedFromProfileUser,
          ),
        );
        if (!uniqueConnectionsMap.containsKey(conn.user.id)) {
          uniqueConnectionsMap[conn.user.id] = conn.copyWith(
            pendingDir: PendingRequestDirection.receivedFromProfileUser,
          );
        } else if (uniqueConnectionsMap[conn.user.id]!.status !=
            ConnectionStatus.accepted) {
          uniqueConnectionsMap[conn.user.id] = conn.copyWith(
            pendingDir: PendingRequestDirection.receivedFromProfileUser,
          );
        }
      }

      setStateIfMounted(() {
        _allConnectionsForGraph = uniqueConnectionsMap.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading network data: $e');
      setStateIfMounted(() {
        _isLoading = false;
        _error = 'خطا در بارگذاری شبکه ارتباطات: ${e.toString()}';
      });
    }
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  void _navigateToUserProfile(String userId) {
    if (userId != _currentUser?.id) {
      Navigator.of(
        context,
      ).pushNamed(OtherUserProfileScreen.routeName, arguments: userId);
    }
  }

  Future<void> _handleAcceptRequest(int connectionId) async {
    try {
      setStateIfMounted(() {
        _isLoading = true;
      });
      await _connectionService.acceptReceivedRequest(connectionId);
      await _loadNetworkData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطا در قبول درخواست: ${e.toString()}")),
      );
      setStateIfMounted(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRejectRequest(int connectionId) async {
    try {
      setStateIfMounted(() {
        _isLoading = true;
      });
      await _connectionService.rejectReceivedRequest(connectionId);
      await _loadNetworkData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطا در رد درخواست: ${e.toString()}")),
      );
      setStateIfMounted(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شبکه و ارتباطات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadNetworkData,
            tooltip: 'بارگذاری مجدد',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.device_hub_rounded), text: 'گراف شبکه'),
            Tab(icon: Icon(Icons.group_add_outlined), text: 'درخواست‌ها'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGraphTab(), _buildRequestsTab()],
      ),
    );
  }

  Widget _buildGraphTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }
    if (_currentUser == null) {
      return const Center(child: Text('اطلاعات کاربر مرکزی یافت نشد.'));
    }
    if (_allConnectionsForGraph.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'هنوز هیچ ارتباطی برای نمایش در گراف وجود ندارد.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return GestureDetector(
      child: CustomPaint(
        key: _graphKey,
        painter: _NetworkGraphPainter(
          currentUser: _currentUser!,
          connections: _allConnectionsForGraph,
          apiService: _apiService,
          onNodeTap: _navigateToUserProfile,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }
    if (_receivedPendingRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('هیچ درخواست اتصال جدیدی ندارید.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _receivedPendingRequests.length,
      itemBuilder: (context, index) {
        final request = _receivedPendingRequests[index];
        final user = request.user;
        String? avatarUrl;
        if (user.profilePictureRelativeUrl != null &&
            user.profilePictureRelativeUrl!.isNotEmpty) {
          avatarUrl =
              _apiService.getBaseUrl() + user.profilePictureRelativeUrl!;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _navigateToUserProfile(user.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? user.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (user.university != null &&
                                user.university!.isNotEmpty)
                              Text(
                                user.university!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "به شما درخواست اتصال داده است.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                          () => _handleRejectRequest(request.connectionId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.7),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('رد کردن'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:
                          () => _handleAcceptRequest(request.connectionId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('پذیرفتن'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NetworkGraphPainter extends CustomPainter {
  final User currentUser;
  final List<ConnectionInfo> connections;
  final ApiService apiService;
  final Function(String userId) onNodeTap;

  final List<Map<String, dynamic>> _nodeDetails = [];

  _NetworkGraphPainter({
    required this.currentUser,
    required this.connections,
    required this.apiService,
    required this.onNodeTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _nodeDetails.clear();

    final Paint linePaint = Paint()..strokeWidth = 1.5;
    final Paint nodePaint = Paint();
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double graphRadius = math.min(size.width, size.height) / 2.7;
    final double centerNodeRadius = 30.0;
    final double connectionNodeRadius = 22.0;
    final double labelOffset = 10.0;

    nodePaint.color = AppTheme.primaryColor;
    canvas.drawCircle(center, centerNodeRadius, nodePaint);
    _drawTextOnNode(
      canvas,
      textPainter,
      currentUser.firstName?.substring(0, 1).toUpperCase() ?? "U",
      center,
      Colors.white,
      centerNodeRadius * 0.6,
    );
    _drawNodeLabel(
      canvas,
      textPainter,
      currentUser.displayName ?? currentUser.email,
      center,
      centerNodeRadius + labelOffset,
      AppTheme.primaryTextColor,
      size,
      isCenter: true,
    );
    _nodeDetails.add({
      'rect': Rect.fromCircle(center: center, radius: centerNodeRadius),
      'userId': currentUser.id,
    });

    if (connections.isEmpty) return;

    final int displayCount = math.min(connections.length, 10);
    final double angleStep =
        (2 * math.pi) / (displayCount > 0 ? displayCount : 1);

    for (int i = 0; i < displayCount; i++) {
      final ConnectionInfo connInfo = connections[i];
      final User nodeUser = connInfo.user;
      final double currentAngle = angleStep * i - (math.pi / 2);

      final Offset nodePosition = Offset(
        center.dx + graphRadius * math.cos(currentAngle),
        center.dy + graphRadius * math.sin(currentAngle),
      );

      Color lineColor = Colors.grey.shade400;
      Color nodeColor = Colors.grey.shade600;
      LineStyle lineStyle = LineStyle.solid;

      switch (connInfo.status) {
        case ConnectionStatus.accepted:
          lineColor = AppTheme.primaryColor.withOpacity(0.6);
          nodeColor = AppTheme.primaryColor;
          break;
        case ConnectionStatus.pending:
          if (connInfo.pendingDirection == PendingRequestDirection.sentByMe) {
            lineColor = AppTheme.accentColor.withOpacity(0.7);
            nodeColor = AppTheme.accentColor;
            lineStyle = LineStyle.dashed;
          } else if (connInfo.pendingDirection ==
              PendingRequestDirection.receivedFromProfileUser) {
            lineColor = Colors.green.shade600.withOpacity(0.7);
            nodeColor = Colors.green.shade600;
            lineStyle = LineStyle.dashed;
          } else {
            lineColor = Colors.purple.withOpacity(0.7);
            nodeColor = Colors.purple;
            lineStyle = LineStyle.dotted;
          }
          break;
        case ConnectionStatus.blocked:
          lineColor = Colors.red.withOpacity(0.4);
          nodeColor = Colors.red.shade700;
          lineStyle = LineStyle.dotted;
          break;
        default:
          break;
      }

      linePaint.color = lineColor;
      if (lineStyle == LineStyle.dashed) {
        _drawDashedLine(canvas, center, nodePosition, [6, 4], linePaint);
      } else if (lineStyle == LineStyle.dotted) {
        _drawDashedLine(canvas, center, nodePosition, [1.5, 3.5], linePaint);
      } else {
        canvas.drawLine(center, nodePosition, linePaint);
      }

      nodePaint.color = nodeColor;
      canvas.drawCircle(nodePosition, connectionNodeRadius, nodePaint);
      _drawTextOnNode(
        canvas,
        textPainter,
        nodeUser.firstName?.substring(0, 1).toUpperCase() ?? "?",
        nodePosition,
        Colors.white,
        connectionNodeRadius * 0.6,
      );
      _drawNodeLabel(
        canvas,
        textPainter,
        nodeUser.displayName ?? nodeUser.email,
        nodePosition,
        connectionNodeRadius + labelOffset,
        nodeColor.withOpacity(1.0),
        size,
      );
      _nodeDetails.add({
        'rect': Rect.fromCircle(
          center: nodePosition,
          radius: connectionNodeRadius,
        ),
        'userId': nodeUser.id,
      });
    }
  }

  void _drawTextOnNode(
    Canvas canvas,
    TextPainter painter,
    String text,
    Offset position,
    Color color,
    double fontSize,
  ) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazir',
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      position - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _drawNodeLabel(
    Canvas canvas,
    TextPainter painter,
    String text,
    Offset nodePosition,
    double offset,
    Color color,
    Size canvasSize, {
    bool isCenter = false,
  }) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: isCenter ? 11 : 10,
        fontFamily: 'Vazir',
        fontWeight: FontWeight.w600,
      ),
    );
    painter.layout(maxWidth: isCenter ? 70 : 55);

    Offset labelPosition = Offset(
      nodePosition.dx - painter.width / 2,
      nodePosition.dy + offset,
    );

    if (labelPosition.dx < 0) labelPosition = Offset(1, labelPosition.dy);
    if (labelPosition.dx + painter.width > canvasSize.width)
      labelPosition = Offset(
        canvasSize.width - painter.width - 1,
        labelPosition.dy,
      );
    if (labelPosition.dy < 0 && !isCenter)
      labelPosition = Offset(
        labelPosition.dx,
        nodePosition.dy - offset - painter.height + 2,
      );
    if (labelPosition.dy + painter.height > canvasSize.height && !isCenter)
      labelPosition = Offset(
        labelPosition.dx,
        nodePosition.dy - offset - painter.height + 2,
      );

    painter.paint(canvas, labelPosition);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    List<double> dashArray,
    Paint paint,
  ) {
    final path =
        ui.Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy);
    final dashedPath = _dashPath(path, dashArray: dashArray);
    canvas.drawPath(dashedPath, paint);
  }

  static ui.Path _dashPath(ui.Path source, {required List<double> dashArray}) {
    final ui.Path dest = ui.Path();
    if (dashArray.isEmpty || dashArray.any((element) => element <= 0)) {
      dest.addPath(source, Offset.zero);
      return dest;
    }

    int dashIndex = 0;
    double distance = 0.0;
    bool draw = true;

    for (final ui.PathMetric metric in source.computeMetrics()) {
      while (distance < metric.length) {
        final double len = dashArray[dashIndex % dashArray.length];
        if (draw) {
          dest.addPath(
            metric.extractPath(
              distance,
              math.min(distance + len, metric.length),
            ),
            ui.Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
        dashIndex++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _NetworkGraphPainter oldDelegate) {
    return oldDelegate.currentUser != currentUser ||
        oldDelegate.connections != connections ||
        oldDelegate.apiService != apiService;
  }

  @override
  bool? hitTest(Offset position) {
    for (final node in _nodeDetails.reversed) {
      final rect = node['rect'] as Rect;
      final userId = node['userId'] as String;
      if (rect.contains(position)) {
        if (userId != currentUser.id) {
          onNodeTap(userId);
        }
        return true;
      }
    }
    return false;
  }
}

enum LineStyle { solid, dashed, dotted }

extension ConnectionInfoCopyWith on ConnectionInfo {
  ConnectionInfo copyWith({
    int? connectionId,
    User? user,
    ConnectionStatus? status,
    DateTime? createdAt,
    PendingRequestDirection? pendingDir,
  }) {
    return ConnectionInfo(
      connectionId: connectionId ?? this.connectionId,
      user: user ?? this.user,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pendingDirection: pendingDir ?? this.pendingDirection,
    );
  }
}
