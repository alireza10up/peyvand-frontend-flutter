class User {
  final String id;
  final String? displayName;
  final String email;
  final String? bio;
  final int? profileFileId;
  final String? profilePictureRelativeUrl;
  final String? university;
  final List<String>? skills;
  final String? firstName;
  final String? lastName;
  final String? birthDate;
  final String? studentCode;
  final DateTime? createdAtDate;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.bio,
    this.profileFileId,
    this.profilePictureRelativeUrl,
    this.university,
    this.skills,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.studentCode,
    this.createdAtDate
  });

  String? get profilePictureUrl => null;

  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? bio,
    int? profileFileId,
    String? profilePictureRelativeUrl,
    bool clearProfilePicture = false,
    String? university,
    List<String>? skills,
    String? firstName,
    String? lastName,
    String? birthDate,
    String? studentCode,
    DateTime? createdAtDate,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileFileId:
          clearProfilePicture ? null : profileFileId ?? this.profileFileId,
      profilePictureRelativeUrl:
          clearProfilePicture
              ? null
              : profilePictureRelativeUrl ?? this.profilePictureRelativeUrl,
      university: university ?? this.university,
      skills: skills ?? this.skills,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      studentCode: studentCode ?? this.studentCode,
      createdAtDate: createdAtDate ?? this.createdAtDate,
    );
  }
}
