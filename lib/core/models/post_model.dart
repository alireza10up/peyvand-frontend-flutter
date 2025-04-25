class PostModel {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final List<String>? imageUrls;
  final int likes;
  final int comments;
  final int shares;
  final UserPreview user;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.imageUrls,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      user: UserPreview.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'user': user.toJson(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class UserPreview {
  final String id;
  final String name;
  final String? title;
  final String? avatarUrl;

  UserPreview({
    required this.id,
    required this.name,
    this.title,
    this.avatarUrl,
  });

  factory UserPreview.fromJson(Map<String, dynamic> json) {
    return UserPreview(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'avatarUrl': avatarUrl,
    };
  }
}