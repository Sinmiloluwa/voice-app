import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voiceapp/core/api_error.dart';
import 'package:voiceapp/models/voice_comment.dart';
import 'package:voiceapp/services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  final _commentService = CommentService();

  List<VoiceComment> _comments = [];
  List<VoiceComment> _filteredComments = [];
  bool _isLoading = false;
  String? _error;
  String _sortFilter = 'recent';

  List<VoiceComment> get comments => _filteredComments.isEmpty ? _comments : _filteredComments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortFilter => _sortFilter;

  /// Load comments for a specific post
  Future<void> loadComments(String postId, {String sortBy = 'recent'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _comments = await _commentService.getComments(postId, sortBy: sortBy);
      _sortFilter = sortBy;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = extractApiError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Post a new comment with audio file
  Future<bool> postComment(
    String postId, {
    required File audioFile,
    required int duration,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final comment = await _commentService.postComment(
        postId,
        audioFile: audioFile,
        duration: duration,
      );
      // Add new comment to the list
      _comments.insert(0, comment);
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

  /// Delete a comment
  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _commentService.deleteComment(postId, commentId);
      
      // Remove from list
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      notifyListeners();
      return false;
    }
  }

  /// Like a comment
  Future<bool> likeComment(String postId, String commentId) async {
    try {
      await _commentService.likeComment(postId, commentId);
      
      // Update like count in local list
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = VoiceComment(
          id: _comments[index].id,
          userId: _comments[index].userId,
          username: _comments[index].username,
          displayName: _comments[index].displayName,
          avatarUrl: _comments[index].avatarUrl,
          audioUrl: _comments[index].audioUrl,
          duration: _comments[index].duration,
          likes: _comments[index].likes + 1,
          replies: _comments[index].replies,
          timeAgo: _comments[index].timeAgo,
          createdAt: _comments[index].createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      notifyListeners();
      return false;
    }
  }

  /// Unlike a comment
  Future<bool> unlikeComment(String postId, String commentId) async {
    try {
      await _commentService.unlikeComment(postId, commentId);
      
      // Update like count in local list
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = VoiceComment(
          id: _comments[index].id,
          userId: _comments[index].userId,
          username: _comments[index].username,
          displayName: _comments[index].displayName,
          avatarUrl: _comments[index].avatarUrl,
          audioUrl: _comments[index].audioUrl,
          duration: _comments[index].duration,
          likes: (_comments[index].likes - 1).clamp(0, double.infinity).toInt(),
          replies: _comments[index].replies,
          timeAgo: _comments[index].timeAgo,
          createdAt: _comments[index].createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = extractApiError(e);
      notifyListeners();
      return false;
    }
  }

  /// Update sort filter
  void updateSortFilter(String sortBy) {
    _sortFilter = sortBy;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
