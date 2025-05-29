import 'package:http_parser/http_parser.dart';

import '../errors/api_exception.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:peyvand/helpers/token_manager.dart';

class ApiService {
  final String _baseUrl = 'https://peyvand.web-dev.sbs';
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    bool isMultipart = false,
  }) async {
    final headers = {
      if (!isMultipart) 'Content-Type': 'application/json; charset=UTF-8',
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

  String getBaseUrl() {
    return _baseUrl;
  }

  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      List<String> errorMessages = ['خطای ناشناخته از سرور'];
      String? errorType = responseBody['error'] as String?;

      if (responseBody['message'] != null) {
        if (responseBody['message'] is List) {
          errorMessages = List<String>.from(
            responseBody['message'].map((m) => m.toString()),
          );
        } else if (responseBody['message'] is String) {
          errorMessages = [responseBody['message'] as String];
        }
      }
      throw ApiException(
        errorType: errorType,
        messages: errorMessages,
        statusCode: response.statusCode,
      );
    }
  }

  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        messages: ['لطفا از اتصال اینترنتی خود اطمینان حاصل کنید.'],
      );
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        messages: ['لطفا از اتصال اینترنتی خود اطمینان حاصل کنید.'],
      );
    }
  }

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        messages: ['لطفا از اتصال اینترنتی خود اطمینان حاصل کنید.'],
      );
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    String? mimeType,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: true, isMultipart: true);

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      MediaType? contentType;
      if (mimeType != null && mimeType.isNotEmpty) {
        try {
          contentType = MediaType.parse(mimeType);
        } catch (e) {
          print(
            'فرمت mimeType نامعتبر است: $mimeType، آپلود بدون contentType صریح برای فایل انجام می‌شود.',
          );
        }
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: contentType,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final dynamic handledResponse = _handleResponse(response);
      if (handledResponse['id'] != null && handledResponse['url'] != null) {
        return {
          'success': true,
          'id': handledResponse['id'],
          'relativeUrl': handledResponse['url'],
        };
      } else {
        throw ApiException(
          messages: ['پاسخ سرور پس از آپلود شامل ID یا URL فایل نبود.'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        messages: ['لطفا از اتصال اینترنتی خود اطمینان حاصل کنید.'],
      );    }
  }
}
