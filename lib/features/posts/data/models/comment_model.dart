import 'package:peyvand/features/profile/data/models/user_model.dart';

class Comment {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final int? parentId;
  final int replyCount;
  List<Comment>? replies;
  bool isLoadingReplies;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.parentId,
    required this.replyCount,
    this.replies,
    this.isLoadingReplies = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    User commentUser;
    if (json['user'] != null && json['user']['id'] != null) {
      commentUser = User(
        id: json['user']['id'].toString(),
        email: json['user']['email'] ?? 'کاربر ناشناس',
        firstName: json['user']['firstName'],
        lastName: json['user']['lastName'],
        displayName: (json['user']['firstName'] != null || json['user']['lastName'] != null)
            ? '${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}'.trim()
            : (json['user']['email'] ?? 'کاربر پیوند'),
        profilePictureRelativeUrl: (json['user']['profileFile'] is Map)
            ? json['user']['profileFile']['url']
            : null,
      );
    } else {
      commentUser = User(id: '0', email: 'کاربر ناشناس', displayName: 'کاربر پیوند');
    }

    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      user: commentUser,
      parentId: json['parentId'],
      replyCount: json['replyCount'] ?? 0,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((i) => Comment.fromJson(i)).toList()
          : null,
    );
  }

  Comment copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    // int? parentId,
    int? replyCount,
    List<Comment>? replies,
    bool? isLoadingReplies,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      parentId: this.parentId,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? (this.replies != null ? List<Comment>.from(this.replies!) : null),
      isLoadingReplies: isLoadingReplies ?? this.isLoadingReplies,
    );
  }
}