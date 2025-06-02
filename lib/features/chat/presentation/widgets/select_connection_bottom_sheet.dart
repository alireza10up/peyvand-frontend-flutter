import 'package:flutter/material.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'package:peyvand/features/connections/data/services/connection_service.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/chat/data/models/chat_user_model.dart' as chat_user_model;

class SelectConnectionBottomSheet extends StatefulWidget {
  final Function(chat_user_model.ChatUserModel selectedUser) onUserSelected;

  const SelectConnectionBottomSheet({super.key, required this.onUserSelected});

  @override
  State<SelectConnectionBottomSheet> createState() =>
      _SelectConnectionBottomSheetState();
}

class _SelectConnectionBottomSheetState
    extends State<SelectConnectionBottomSheet> {
  final ConnectionService _connectionService = ConnectionService();
  final ApiService _apiService = ApiService();
  List<ConnectionInfo> _allConnections = [];
  List<ConnectionInfo> _filteredConnections = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAcceptedConnections();
    _searchController.addListener(_filterConnections);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterConnections);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAcceptedConnections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final connections = await _connectionService.getAcceptedConnections();
      if (mounted) {
        setState(() {
          _allConnections = connections;
          _filteredConnections = connections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "خطا در دریافت لیست دوستان: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _filterConnections() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredConnections = _allConnections;
      });
    } else {
      setState(() {
        _filteredConnections = _allConnections.where((conn) {
          final userName = conn.user.displayName?.toLowerCase() ?? '';
          final userEmail = conn.user.email.toLowerCase();
          return userName.contains(query) || userEmail.contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container( // Handle
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Text(
              'انتخاب مخاطب برای گفتگو',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی دوست...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible( // Makes ListView scrollable within the bottom sheet's constraints
            child: _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : _error != null
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ))
                    : _filteredConnections.isEmpty
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_searchController.text.isEmpty ? 'هنوز هیچ دوست متصلی ندارید.' : 'هیچ دوستی با این مشخصات یافت نشد.'),
                          ))
                        : ListView.builder(
                            shrinkWrap: true, // Important for Column > Flexible > ListView
                            itemCount: _filteredConnections.length,
                            itemBuilder: (context, index) {
                              final connection = _filteredConnections[index];
                              final user = connection.user;
                              String? avatarUrl;
                              if (user.profilePictureRelativeUrl != null &&
                                  user.profilePictureRelativeUrl!.isNotEmpty) {
                                avatarUrl = _apiService.getBaseUrl() +
                                    user.profilePictureRelativeUrl!;
                              }
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: avatarUrl != null
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: avatarUrl == null
                                      ? Text(user.displayName?.substring(0, 1).toUpperCase() ?? "?", style: const TextStyle(color: Colors.white))
                                      : null,
                                  backgroundColor: avatarUrl == null ? AppTheme.primaryColor.withOpacity(0.6) : Colors.transparent,
                                ),
                                title: Text(user.displayName ?? user.email),
                                subtitle: Text(user.university ?? 'دانشگاه نامشخص', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                onTap: () {
                                  final chatUser = chat_user_model.ChatUserModel(
                                    id: user.id.toString(),
                                    email: user.email,
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    displayName: user.displayName,
                                    profilePictureRelativeUrl: user.profilePictureRelativeUrl,
                                  );
                                  widget.onUserSelected(chatUser);
                                  Navigator.of(context).pop(); // Close the bottom sheet
                                },
                              );
                            },
                          ),
          ),
          // Padding for bottom safe area if needed, or rely on parent Scaffold's FAB handling
           SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}