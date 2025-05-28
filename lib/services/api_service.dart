import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:peyvand/helpers/token_manager.dart';

class ApiService {
  final String _baseUrl = 'http://154.16.16.2:9090';
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = await _tokenManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      return await http.get(url, headers: headers);
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      return await http.post(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      return await http.patch(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      return await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception('خطا در برقراری ارتباط با سرور: $e');
    }
  }
}
