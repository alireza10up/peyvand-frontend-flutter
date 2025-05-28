import 'package:flutter/material.dart';
import 'package:peyvand/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _authMessage;


  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authMessage => _authMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    _isAuthenticated = await _authService.isAuthenticated;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _authMessage = null;
    notifyListeners();
    final result = await _authService.login(email, password);
    if (result['success'] == true) {
      _isAuthenticated = true;
      _authMessage = result['message'];
    } else {
      _isAuthenticated = false;
      _authMessage = result['message'];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _authMessage = null;
    notifyListeners();
    final result = await _authService.register(
      email: email,
      password: password,
    );
    if (result['success'] == true) {
      final token = await _authService.isAuthenticated;
      if(token){
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
      _authMessage = result['message'];
    } else {
      _isAuthenticated = false;
      _authMessage = result['message'];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
    _isAuthenticated = false;
    _authMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    _authMessage = null;
    notifyListeners();
  }
}