import 'dart:io';
import 'package:dio/dio.dart';
import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/voice_post.dart';

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

  Future<List<VoicePost>> getFeed({bool trending = false}) async {
    final res = await api.post(
      "/voice/feed",
      queryParameters: trending ? {"trending": true} : null,
    );
    return (res.data as List).map((e) => VoicePost.fromJson(e)).toList();
  }

  Future<List<VoicePost>> getMyUploads() async {
    final res = await api.post("/voice/my-uploads");
    return (res.data as List).map((e) => VoicePost.fromJson(e)).toList();
  }
}
