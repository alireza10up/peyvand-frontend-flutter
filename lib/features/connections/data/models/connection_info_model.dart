import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'connection_status.dart';
import 'pending_request_direction.dart';

class ConnectionInfo {
  final int connectionId;
  final User user;
  final ConnectionStatus status;
  final DateTime? createdAt;
  final PendingRequestDirection pendingDirection;

  ConnectionInfo({
    required this.connectionId,
    required this.user,
    required this.status,
    this.createdAt,
    this.pendingDirection = PendingRequestDirection.none,
  });

  factory ConnectionInfo.fromJson(Map<String, dynamic> json, {PendingRequestDirection direction = PendingRequestDirection.none}) {
    Map<String, dynamic> userJson = json['user'] as Map<String, dynamic>? ?? {};
    String? profileUrl;
    if (userJson['profileFile'] != null && userJson['profileFile'] is Map) {
      profileUrl = userJson['profileFile']['url'] as String?;
    }

    String? displayName = userJson['displayName'] as String?;
    if (displayName == null || displayName.trim().isEmpty) {
      displayName = (userJson['firstName'] != null || userJson['lastName'] != null)
          ? '${userJson['firstName'] ?? ''} ${userJson['lastName'] ?? ''}'.trim()
          : (userJson['email'] ?? 'کاربر پیوند');
      if (displayName!.trim().isEmpty) displayName = userJson['email'] ?? 'کاربر پیوند';
    }

    return ConnectionInfo(
      connectionId: json['id'] as int,
      user: User(
        id: userJson['id']?.toString() ?? 'unknown',
        email: userJson['email'] ?? 'N/A',
        firstName: userJson['firstName'] as String?,
        lastName: userJson['lastName'] as String?,
        displayName: displayName,
        profilePictureRelativeUrl: profileUrl,
        studentCode: userJson['studentCode'] as String?,
        university: userJson['university'] as String?,
        bio: userJson['bio'] as String?,
        createdAtDate: userJson['createdAt'] != null
            ? DateTime.tryParse(userJson['createdAt'] as String)
            : null,
        birthDate: userJson['birthDate'] as String?,
      ),
      status: ConnectionStatus.fromString(json['status'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      pendingDirection: direction,
    );
  }
}