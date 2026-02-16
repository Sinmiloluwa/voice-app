import 'dart:io';
import 'package:dio/dio.dart';
import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/voice_post.dart';

enum FeedType {
  forYou('for-you'),
  trending('trending'),
  following('following');

  final String value;
  const FeedType(this.value);
}

class VoiceApi {
  final api = ApiClient().dio;

  Future<void> uploadVoice({
    required File audioFile,
    required int duration,
    String? title,
  }) async {
    final formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(
        audioFile.path,
        filename: "voice.m4a",
      ),
      "duration": duration,
      if (title != null) "title": title,
    });

    await api.post("/voice/upload", data: formData);
  }

  Future<List<VoicePost>> getFeed({FeedType type = FeedType.forYou}) async {
    final res = await api.get("/voice/feed?${type.value}");
    return (res.data as List).map((e) => VoicePost.fromJson(e)).toList();
  }

  Future<List<VoicePost>> getMyUploads() async {
    final res = await api.get("/voice/my-uploads");
    return (res.data as List).map((e) => VoicePost.fromJson(e)).toList();
  }
}
