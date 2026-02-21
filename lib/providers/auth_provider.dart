import 'package:flutter/material.dart';
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

  Future<bool> loginAnonymous(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.anonymousLogin(username);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      _error = e.toString();
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
