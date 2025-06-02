import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:peyvand/helpers/token_manager.dart';
import 'package:flutter/foundation.dart';

class SocketService {
  io.Socket? _socket;
  final TokenManager _tokenManager = TokenManager();
  final String _socketUrl = 'https://peyvand.web-dev.sbs';

  io.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      debugPrint('SocketService: Already connected.');
      return;
    }

    final token = await _tokenManager.getToken();
    if (token == null) {
      debugPrint('SocketService: No auth token found, cannot connect.');
      return;
    }

    try {
      _socket = io.io(_socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'extraHeaders': {'Authorization': 'Bearer $token'}
      });

      _socket!.onConnect((_) {
        debugPrint('SocketService: Connected to socket server.');
      });

      _socket!.onDisconnect((reason) {
        debugPrint('SocketService: Disconnected from socket server. Reason: $reason');
      });

      _socket!.onConnectError((data) {
        debugPrint('SocketService: Connection error: $data');
      });

      _socket!.onError((data) {
        debugPrint('SocketService: Socket error: $data');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('SocketService: Error initializing socket: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    debugPrint('SocketService: Disconnected and disposed.');
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
    } else {
      debugPrint('SocketService: Cannot emit event, socket not connected.');
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    _socket?.off(event, handler);
  }
}