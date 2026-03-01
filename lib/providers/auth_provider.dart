import 'package:flutter/material.dart';
import 'package:voiceapp/core/api_error.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> checkSession() async {
    final token = await _authService.getSavedToken();
    return token != null;
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.login(identifier, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.register(username, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginGoogle(String idToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.googleLogin(idToken);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
