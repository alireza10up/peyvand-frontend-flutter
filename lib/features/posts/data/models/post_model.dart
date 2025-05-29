import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'post_status_enum.dart';

class PostFile {
  final int id;
  final String filename;
  final String mimetype;
  final String url;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  PostFile({
    required this.id,
    required this.filename,
    required this.mimetype,
    required this.url,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory PostFile.fromJson(Map<String, dynamic> json) {
    return PostFile(
      id: json['id'],
      filename: json['filename'],
      mimetype: json['mimetype'],
      url: json['url'],
      visibility: json['visibility'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}

class Post {
  final int id;
  final String? title;
  final String content;
  final User user;
  final PostStatus status;
  final List<PostFile> files;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    this.title,
    required this.content,
    required this.user,
    required this.status,
    required this.files,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var filesList = json['files'] as List? ?? [];
    List<PostFile> postFiles =
        filesList.map((i) => PostFile.fromJson(i)).toList();

    User postUser;
    if (json['user'] is Map<String, dynamic> &&
        json['user']['id'] != null &&
        json['user']['email'] != null) {
      postUser = User(
        id: json['user']['id'].toString(),
        email: json['user']['email'],
        firstName: json['user']['firstName'],
        lastName: json['user']['lastName'],
        displayName:
            (json['user']['firstName'] != null ||
                    json['user']['lastName'] != null)
                ? '${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}'
                    .trim()
                : json['user']['email'],
        bio: json['user']['bio'],
        profileFileId:
            json['user']['profileFile'] is Map
                ? json['user']['profileFile']['id']
                : (json['user']['profileFile'] is int
                    ? json['user']['profileFile']
                    : null),
        profilePictureRelativeUrl:
            json['user']['profileFile'] is Map
                ? json['user']['profileFile']['url']
                : null,
        university: json['user']['university'],
        skills:
            json['user']['skills'] != null
                ? List<String>.from(json['user']['skills'])
                : null,
        birthDate: json['user']['birthDate'],
        studentCode: json['user']['studentCode'],
      );
    } else if (json['user'] is Map<String, dynamic> &&
        json['user']['id'] != null) {
      postUser = User(
        id: json['user']['id'].toString(),
        email: json['user']['email'] ?? 'unknown@example.com',
      );
    } else {
      postUser = User(id: 'unknown', email: 'unknown@example.com');
    }

    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      user: postUser,
      status: PostStatus.fromString(json['status']),
      files: postFiles,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
