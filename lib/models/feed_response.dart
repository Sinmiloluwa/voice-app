import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/models/voice_post.dart';

class FeedResponse {
  final List<VoicePost> voices;
  final List<UserModel> users;
  final List<String> tags;

  FeedResponse({
    required this.voices,
    required this.users,
    required this.tags,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final posts = json["posts"] ?? {};
    final voicesList = posts["voices"] ?? [];
    final usersList = json["users"] ?? [];
    final tagsList = json["tags"] ?? [];

    return FeedResponse(
      voices: (voicesList as List).map((e) => VoicePost.fromJson(e)).toList(),
      users: (usersList as List).map((e) => UserModel.fromJson(e)).toList(),
      tags: List<String>.from(tagsList),
    );
  }
}
