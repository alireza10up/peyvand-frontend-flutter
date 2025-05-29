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
      final response = await _apiService.post('/auth/signIn', {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (response['accessToken'] != null) {
        await _tokenManager.saveToken(response['accessToken']);
        return {'success': true, 'message': 'ورود موفقیت آمیز بود.'};
      } else {
        return {'success': false, 'message': 'پاسخ سرور نامعتبر است.'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/signUp', {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (response['accessToken'] != null) {
        await _tokenManager.saveToken(response['accessToken']);
        return {'success': true, 'message': 'خوش آمدید.'};
      } else {
        return {'success': false, 'message': 'پاسخ سرور نامعتبر است.'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _tokenManager.deleteToken();
  }
}
