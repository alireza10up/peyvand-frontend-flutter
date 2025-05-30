import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/features/connections/data/models/connection_info_model.dart';
import 'package:peyvand/features/connections/data/models/connection_status.dart';

class ConnectionService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getConnectionStatusWithUser(
    String userId,
  ) async {
    try {
      final response = await _apiService.get('/connections/status/$userId');
      return {
        'userId': response['userId'],
        'status': ConnectionStatus.fromString(response['status']),
        'connectionId': response['connectionId'],
      };
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        return {
          'userId': int.tryParse(userId),
          'status': ConnectionStatus.notSend,
          'connectionId': null,
        };
      }
      rethrow;
    }
  }

  Future<ConnectionInfo> sendConnectionRequest(String receiverId) async {
    try {
      final response = await _apiService.post('/connections/send-request', {
        'receiverId': int.parse(receiverId),
      });
      return ConnectionInfo.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelSentRequest(int connectionRequestId) async {
    try {
      await _apiService.delete(
        '/connections/send-request/$connectionRequestId',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ConnectionInfo> acceptReceivedRequest(int connectionRequestId) async {
    try {
      final response = await _apiService.patch(
        '/connections/requests/$connectionRequestId/accept',
        {},
      );
      return ConnectionInfo.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ConnectionInfo> rejectReceivedRequest(int connectionRequestId) async {
    try {
      final response = await _apiService.patch(
        '/connections/requests/$connectionRequestId/reject',
        {},
      );
      return ConnectionInfo.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConnectionInfo>> getReceivedPendingRequests() async {
    try {
      final response = await _apiService.get('/connections/requests/received');
      if (response is List) {
        return response.map((data) => ConnectionInfo.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConnectionInfo>> getSentPendingRequests() async {
    try {
      final response = await _apiService.get('/connections/requests/sent');
      if (response is List) {
        return response.map((data) => ConnectionInfo.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConnectionInfo>> getAcceptedConnections() async {
    try {
      final response = await _apiService.get('/connections/');
      if (response is List) {
        return response.map((data) => ConnectionInfo.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteConnection(int connectionId) async {
    try {
      await _apiService.delete('/connections/$connectionId');
    } catch (e) {
      rethrow;
    }
  }

  Future<ConnectionInfo> blockUser(String userId) async {
    try {
      final response = await _apiService.post('/connections/block', {
        'userId': int.parse(userId),
      });
      return ConnectionInfo.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _apiService.delete('/connections/unblock/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConnectionInfo>> getConnectionsForUser(
    String targetUserId,
  ) async {
    try {
      final response = await _apiService.get('/connections/user/$targetUserId');
      if (response is List) {
        return response
            .map(
              (data) => ConnectionInfo.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching connections for user $targetUserId: $e');
      rethrow;
    }
  }
}
