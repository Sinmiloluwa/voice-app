import 'package:flutter/material.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/models/voice_post.dart';
import 'package:voiceapp/services/voice_service.dart';

class FeedProvider extends ChangeNotifier {
  final _voiceApi = VoiceApi();

  List<VoicePost> _posts = [];
  List<UserModel> _users = [];
  List<String> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<VoicePost> get posts => _posts;
  List<UserModel> get users => _users;
  List<String> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _updatePost(String postId, VoicePost Function(VoicePost) update) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    _posts[index] = update(_posts[index]);
    notifyListeners();
  }

  Future<void> reactToPost(String postId, String emoji) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final oldReaction = post.myReaction;

    final newReactions = Map<String, int>.from(post.reactions);
    if (oldReaction != null) {
      newReactions[oldReaction] = (newReactions[oldReaction] ?? 1) - 1;
      if (newReactions[oldReaction]! <= 0) newReactions.remove(oldReaction);
    }

    if (oldReaction == emoji) {
      _updatePost(postId, (p) => p.copyWith(
        reactions: newReactions,
        myReaction: () => null,
      ));
      try {
        await _voiceApi.removeReaction(postId);
      } catch (_) {
        _updatePost(postId, (_) => post);
      }
    } else {
      newReactions[emoji] = (newReactions[emoji] ?? 0) + 1;
      _updatePost(postId, (p) => p.copyWith(
        reactions: newReactions,
        myReaction: () => emoji,
      ));
      try {
        await _voiceApi.addReaction(postId, emoji);
      } catch (_, e) {
        print(e);
        _updatePost(postId, (_) => post);
      }
    }
  }

  Future<void> loadFeed({FeedType type = FeedType.forYou}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _voiceApi.getFeed(type: type);
      _posts = response.voices;
      _users = response.users;
      _tags = response.tags;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPost(String query) async{
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _voiceApi.searchPost(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print(_error);
      _isLoading = false;
      notifyListeners();
    }
  }
}
