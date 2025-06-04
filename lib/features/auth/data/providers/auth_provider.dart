import 'package:flutter/material.dart';
import 'package:peyvand/features/auth/data/services/auth_service.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialLoading = true;
  bool _isActionLoading = false;
  String? _authMessage;
  bool _disposed = false;

  User? get currentUser => _currentUser;

  String? get currentUserId => _currentUser?.id.toString();

  bool get isAuthenticated => _isAuthenticated;

  bool get isInitialLoading => _isInitialLoading;

  bool get isActionLoading => _isActionLoading;

  String? get authMessage => _authMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> _checkLoginStatus() async {
    if (_disposed) return;

    _isInitialLoading = true;
    notifyListeners();

    _isAuthenticated = await _authService.isAuthenticated;
    if (_disposed) return;

    if (_isAuthenticated) {
      await _fetchCurrentUserProfile();
      if (_disposed) return;

      if (_currentUser == null) {
        _isAuthenticated = false;
        await _authService.logout();
        if (_disposed) return;
        _authMessage =
            "خطا در بارگذاری اطلاعات کاربری. لطفاً دوباره وارد شوید.";
      }
    } else {
      _currentUser = null;
    }

    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCurrentUserProfile() async {
    if (_disposed || !_isAuthenticated) {
      _currentUser = null;
      return;
    }

    try {
      _currentUser = await _userService.fetchUserProfile();
      if (_disposed) return;
    } catch (e) {
      if (_disposed) return;
      print("Error fetching user profile in AuthProvider: $e");
      _currentUser = null;
      _authMessage = "خطا در دریافت اطلاعات پروفایل.";
    }
  }

  Future<bool> login(String email, String password) async {
    if (_disposed) return false;

    _isActionLoading = true;
    _authMessage = null;
    _currentUser = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      if (_disposed) return false;

      if (result['success'] == true) {
        _isAuthenticated = true;
        await _fetchCurrentUserProfile();
        if (_disposed) return false;

        if (_currentUser != null) {
          _authMessage = result['message'] ?? 'ورود با موفقیت انجام شد!';
          _isActionLoading = false;
          notifyListeners();
          return true;
        } else {
          _isAuthenticated = false;
          _authMessage =
              "ورود موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
          _isActionLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        _authMessage =
            result['message'] ?? 'خطا در ورود. لطفاً دوباره تلاش کنید.';
        _isActionLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      print("Login error: $e");
      _isAuthenticated = false;
      _currentUser = null;
      _authMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    if (_disposed) return false;

    _isActionLoading = true;
    _authMessage = null;
    _currentUser = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
      );
      if (_disposed) return false;

      if (result['success'] == true) {
        _isAuthenticated = true;
        await _fetchCurrentUserProfile();
        if (_disposed) return false;

        if (_currentUser != null) {
          _authMessage =
              result['message'] ?? 'ثبت نام و ورود با موفقیت انجام شد.';
          _isActionLoading = false;
          notifyListeners();
          return true;
        } else {
          _isAuthenticated = false;
          _authMessage =
              "ثبت نام موفق بود اما دریافت اطلاعات پروفایل با خطا مواجه شد.";
          _isActionLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _isAuthenticated = false;
        _authMessage =
            result['message'] ?? 'خطا در ثبت نام. لطفاً دوباره تلاش کنید.';
        _isActionLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      print("Register error: $e");
      _isAuthenticated = false;
      _currentUser = null;
      _authMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_disposed) return;

    _isActionLoading = true;
    notifyListeners();

    await _authService.logout();
    if (_disposed) return;

    _isAuthenticated = false;
    _currentUser = null;
    _authMessage = null;
    _isActionLoading = false;
    notifyListeners();
  }

  void clearMessage() {
    if (_disposed) return;
    _authMessage = null;
    notifyListeners();
  }
}
