import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/voice_comment.dart';

class CommentService {
  final api = ApiClient().dio;

  /// Get all comments for a specific post
  Future<List<VoiceComment>> getComments(String postId, {String sortBy = 'recent'}) async {
    try {
      
      final res = await api.get(
        '/voice/$postId/comments',
        queryParameters: {'sort': sortBy},
      );

      
      final data = res.data;
      List<VoiceComment> comments = [];
      
      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          try {
            final comment = VoiceComment.fromJson(data[i] as Map<String, dynamic>);
            comments.add(comment);
          } catch (e) {
            print('CommentService: Error parsing item $i: $e');
          }
        }
      } else if (data is Map && data['comments'] != null) {
        final commentsList = data['comments'] as List;
        for (int i = 0; i < commentsList.length; i++) {
          try {
            final comment = VoiceComment.fromJson(commentsList[i] as Map<String, dynamic>);
            comments.add(comment);
          } catch (e) {
            print('CommentService: Error parsing item $i: $e');
          }
        }
      } else if (data is Map && data['data'] != null) {
        final commentsList = data['data'] as List;
        for (int i = 0; i < commentsList.length; i++) {
          try {
            final comment = VoiceComment.fromJson(commentsList[i] as Map<String, dynamic>);
            comments.add(comment);
          } catch (e) {
            print('CommentService: Error parsing item $i: $e');
          }
        }
      }
      return comments;
    } catch (e) {
      print('CommentService: Error fetching comments: $e');
      rethrow;
    }
  }

  /// Post a new voice comment with audio file
  Future<VoiceComment> postComment(
    String postId, {
    required File audioFile,
    required int duration,
  }) async {
    try {
      
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'comment.m4a',
        ),
        'duration': duration,
      });
      
      final res = await api.post(
        '/voice/$postId/comments',
        data: formData,
      );

      final comment = VoiceComment.fromJson(res.data);
      return comment;
    } catch (e) {
      print('CommentService.postComment: Error posting comment: $e');
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await api.delete('/voice/$postId/$commentId');
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Like a comment
  Future<void> likeComment(String postId, String commentId) async {
    try {
      await api.post('/voice/$postId/$commentId/like');
    } catch (e) {
      print('Error liking comment: $e');
      rethrow;
    }
  }

  /// Unlike a comment
  Future<void> unlikeComment(String postId, String commentId) async {
    try {
      await api.delete('/voice/$postId/$commentId/like');
    } catch (e) {
      print('Error unliking comment: $e');
      rethrow;
    }
  }
}
