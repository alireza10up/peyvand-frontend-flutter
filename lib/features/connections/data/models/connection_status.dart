enum ConnectionStatus {
  accepted,
  pending,
  rejected,
  blocked,
  notSend,
  loading;

  static ConnectionStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'pending':
        return ConnectionStatus.pending;
      case 'rejected':
        return ConnectionStatus.rejected;
      case 'blocked':
        return ConnectionStatus.blocked;
      case 'not_send':
      case 'not_sent':
        return ConnectionStatus.notSend;
      default:
        return ConnectionStatus.loading;
    }
  }

  String get displayName {
    switch (this) {
      case ConnectionStatus.accepted:
        return 'اتصال برقرار شد';
      case ConnectionStatus.pending:
        return 'درخواست ارسال شد';
      case ConnectionStatus.rejected:
        return 'درخواست رد شد';
      case ConnectionStatus.blocked:
        return 'بلاک شده';
      case ConnectionStatus.notSend:
        return 'ارسال درخواست';
      case ConnectionStatus.loading:
        return 'درحال بررسی...';
    }
  }
}