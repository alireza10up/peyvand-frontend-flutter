enum MessageStatus {
  SENT,
  DELIVERED,
  READ,
  FAILED,
  UNKNOWN;

  static MessageStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'SENT':
        return MessageStatus.SENT;
      case 'READ':
        return MessageStatus.READ;
      default:
        return MessageStatus.UNKNOWN;
    }
  }

  @override
  String toString() {
    return name.toUpperCase();
  }
}
