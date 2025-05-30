import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'connection_status.dart';

class ConnectionInfo {
  final int connectionId;
  final User user;
  final ConnectionStatus status;
  final DateTime? createdAt;

  ConnectionInfo({
    required this.connectionId,
    required this.user,
    required this.status,
    this.createdAt,
  });

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userJson = json['user'] ?? json['requester'] ?? json['receiver'] ?? {};
    String? profileUrl;
    if (userJson['profileFile'] != null && userJson['profileFile'] is Map) {
      profileUrl = userJson['profileFile']['url'];
    }


    return ConnectionInfo(
      connectionId: json['id'] as int,
      user: User(
        id: userJson['id'].toString(),
        email: userJson['email'] ?? 'N/A',
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        displayName: (userJson['firstName'] != null || userJson['lastName'] != null)
            ? '${userJson['firstName'] ?? ''} ${userJson['lastName'] ?? ''}'.trim()
            : (userJson['email'] ?? 'کاربر پیوند'),
        profilePictureRelativeUrl: profileUrl,
        studentCode: userJson['studentCode'],
        university: userJson['university'],
        bio: userJson['bio'],
      ),
      status: ConnectionStatus.fromString(json['status'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}