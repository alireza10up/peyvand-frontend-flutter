class ChatAttachmentModel {
  final int id;
  final String url;
  final String filename;
  final String mimetype;

  ChatAttachmentModel({
    required this.id,
    required this.url,
    required this.filename,
    required this.mimetype,
  });

  factory ChatAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ChatAttachmentModel(
      id: json['id'] as int,
      url: json['url'] as String,
      filename: json['filename'] as String,
      mimetype: json['mimetype'] as String,
    );
  }
}