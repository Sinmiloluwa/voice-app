import 'package:flutter/material.dart';
import 'package:voiceapp/models/voice_post.dart';
import 'package:voiceapp/services/voice_service.dart';

class FeedProvider extends ChangeNotifier {
  final _voiceApi = VoiceApi();

  List<VoicePost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<VoicePost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeed({FeedType type = FeedType.forYou}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _voiceApi.getFeed(type: type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
