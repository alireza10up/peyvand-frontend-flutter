import 'dart:convert';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/helpers/token_manager.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final TokenManager _tokenManager = TokenManager();

  Future<bool> get isAuthenticated async {
    final token = await _tokenManager.getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/signIn',
        {'email': email, 'password': password},
        includeAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['accessToken'] != null) {
          await _tokenManager.saveToken(responseData['accessToken']);
          return {'success': true, 'message': 'ورود موفقیت آمیز بود.'};
        } else {
          return {'success': false, 'message': 'پاسخ سرور نامعتبر است.'};
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'خطا در ورود';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] is List ? errorData['message'].join('\n') : errorData['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطا در ارتباط با سرور: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/signUp',
        {'email': email, 'password': password},
        includeAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['accessToken'] != null) {
          await _tokenManager.saveToken(responseData['accessToken']);
          return {'success': true, 'message': 'خوش آمدید.'};
        } else {
          return {'success': false, 'message': 'پاسخ سرور نامعتبر است.'};
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'خطا در ثبت نام';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'] is List ? errorData['message'].join('\n') : errorData['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'خطا در ارتباط با سرور: $e'};
    }
  }

  Future<void> logout() async {
    await _tokenManager.deleteToken();
  }
}