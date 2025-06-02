import 'package:peyvand/features/profile/data/models/user_model.dart' as profile_user_model;

class ChatUserModel {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? profilePictureRelativeUrl;

  ChatUserModel({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.profilePictureRelativeUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    String? calculatedDisplayName = json['displayName'] as String?;

    if (calculatedDisplayName == null || calculatedDisplayName
        .trim()
        .isEmpty) {
      final fName = json['firstName'] as String?;
      final lName = json['lastName'] as String?;

      if (fName != null && fName.isNotEmpty ||
          lName != null && lName.isNotEmpty) {
        calculatedDisplayName = ('${fName ?? ''} ${lName ?? ''}').trim();
      } else {
        calculatedDisplayName = json['email'] as String?;
      }
    }

    if (calculatedDisplayName != null && calculatedDisplayName
        .trim()
        .isEmpty) {
      calculatedDisplayName = json['email'] as String?;
    }

    String? profilePictureRelativeUrl = null;

    if (json['profileFile'] is Map && json['profileFile']['url'] != null) {
      profilePictureRelativeUrl = json['profileFile']['url'] as String?;
    }

    return ChatUserModel(
        id: json['id'].toString(),
        email: json['email'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        displayName: calculatedDisplayName,
        profilePictureRelativeUrl: profilePictureRelativeUrl
    );
  }

  factory ChatUserModel.fromProfileUser(profile_user_model.User user) {
    return ChatUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      displayName: user.displayName,
      profilePictureRelativeUrl: user.profilePictureRelativeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'profilePictureRelativeUrl': profilePictureRelativeUrl,
    };
  }
}