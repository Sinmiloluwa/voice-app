import 'package:flutter/material.dart';
import 'package:voiceapp/models/voice_post.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/services/voice_service.dart';
import 'package:voiceapp/services/user_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _voiceApi = VoiceApi();
  final _userService = UserService();

  List<VoicePost> _myUploads = [];
  List<UserModel> _following = [];
  bool _isLoading = false;
  String? _error;

  List<VoicePost> get myUploads => _myUploads;
  List<UserModel> get following => _following;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyUploads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myUploads = await _voiceApi.getMyUploads();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFollowing() async {
    try {
      _following = await _userService.getFollowing();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      await _userService.followUser(userId);
      await loadFollowing();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      await _userService.unfollowUser(userId);
      await loadFollowing();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
