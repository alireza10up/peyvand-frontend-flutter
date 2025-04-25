class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? title;
  final String? company;
  final String? location;
  final String? about;
  final List<String>? skills;
  final String? avatarUrl;
  final int connections;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.title,
    this.company,
    this.location,
    this.about,
    this.skills,
    this.avatarUrl,
    this.connections = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      about: json['about'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      avatarUrl: json['avatarUrl'],
      connections: json['connections'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'title': title,
      'company': company,
      'location': location,
      'about': about,
      'skills': skills,
      'avatarUrl': avatarUrl,
      'connections': connections,
    };
  }
}