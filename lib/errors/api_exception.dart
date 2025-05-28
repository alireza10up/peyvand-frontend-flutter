class ApiException implements Exception {
  final String? errorType;
  final List<String> messages;
  final int? statusCode;

  ApiException({
    this.errorType,
    required this.messages,
    this.statusCode,
  });

  @override
  String toString() {
    return messages.join('\n');
  }

  String get combinedMessage => messages.join('\n');
}