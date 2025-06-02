import 'package:flutter/material.dart';
import 'package:peyvand/features/auth/data/services/auth_service.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _authMessage;

  User? get currentUser => _currentUser;

  String? get currentUserId => _currentUser?.id.toString();

  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get authMessage => _authMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    _isAuthenticated = await _authService.isAuthenticated;
    if (_isAuthenticated) {
      await _fetchCurrentUserProfile();
      if (_currentUser == null) {
        _isAuthenticated = false;
        await _authService.logout();
        _authMessage = "خطا در بارگذاری اطلاعات کاربری. لطفاً دوباره وارد شوید.";
      }
    } else {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCurrentUserProfile() async {
    if (!_isAuthenticated) {
      _currentUser = null;
      return;
    }
    try {
      _currentUser = await _userService.fetchUserProfile();
    } catch (e) {
      print("Error fetching user profile in AuthProvider: $e");
      _currentUser = null;
      _authMessage = "خطا در دریافت اطلاعات پروفایل.";
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _authMessage = null;
    _currentUser = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      _isAuthenticated = true;
      try {
        await _fetchCurrentUserProfile();
        if (_currentUser != null) {
          _authMessage = result['message'];
        } else {
          _isAuthenticated = false;
          _authMessage = "ورود موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
        }
      } catch (e) {
        print("Login successful, but failed to fetch profile: $e");
        _isAuthenticated = false;
        _currentUser = null;
        _authMessage = "ورود موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
      }
    } else {
      _isAuthenticated = false;
      _currentUser = null;
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
    _currentUser = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      _isAuthenticated = true;
      try {
        await _fetchCurrentUserProfile();
        if (_currentUser != null) {
          _authMessage = result['message'] ?? 'ثبت نام و ورود با موفقیت انجام شد.';
        } else {
          _isAuthenticated = false;
          _authMessage = "ثبت نام موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
        }
      } catch (e) {
        print("Register successful, but failed to fetch profile: $e");
        _isAuthenticated = false;
        _currentUser = null;
        _authMessage = "ثبت نام موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
      }

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
    _currentUser = null;
    _authMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    _authMessage = null;
    notifyListeners();
  }
}