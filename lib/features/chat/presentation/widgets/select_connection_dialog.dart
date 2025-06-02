import 'package:flutter/material.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'package:peyvand/features/connections/data/services/connection_service.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/features/chat/data/models/chat_user_model.dart' as chat_user_model;

class SelectConnectionForChatDialog extends StatefulWidget {
  final Function(chat_user_model.ChatUserModel selectedUser) onUserSelected;

  const SelectConnectionForChatDialog({super.key, required this.onUserSelected});

  @override
  State<SelectConnectionForChatDialog> createState() =>
      _SelectConnectionForChatDialogState();
}

class _SelectConnectionForChatDialogState
    extends State<SelectConnectionForChatDialog> {
  final ConnectionService _connectionService = ConnectionService();
  final ApiService _apiService = ApiService();
  List<ConnectionInfo> _connections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAcceptedConnections();
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
          _connections = connections;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('انتخاب مخاطب برای گفتگو'),
      contentPadding: const EdgeInsets.only(top: 12.0, right: 0, left: 0, bottom: 0),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ))
            : _connections.isEmpty
            ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('هنوز هیچ دوست متصلی ندارید.'),
            ))
            : ListView.builder(
          shrinkWrap: true,
          itemCount: _connections.length,
          itemBuilder: (context, index) {
            final connection = _connections[index];
            final user = connection.user;
            String? avatarUrl;
            if (user.profilePictureRelativeUrl != null &&
                user.profilePictureRelativeUrl!.isNotEmpty) {
              avatarUrl = _apiService.getBaseUrl() +
                  user.profilePictureRelativeUrl!;
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(user.displayName?.substring(0, 1).toUpperCase() ?? "?")
                    : null,
              ),
              title: Text(user.displayName ?? user.email),
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
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('انصراف'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}