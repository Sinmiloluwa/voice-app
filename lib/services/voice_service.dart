import 'dart:io';
import 'package:dio/dio.dart';
import 'package:voiceapp/core/api_client.dart';

class VoiceApi {
  final api = ApiClient().dio;

  Future uploadVoice({
    required File audioFile,
    required int duration,
  }) async {
    final formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(
        audioFile.path,
        filename: "voice.m4a",
      ),
      "duration": duration,
    });

    await api.post("/voice/upload", data: formData);
  }

  Future<List<dynamic>> getFeed() async {
    final res = await api.get("/voice/feed");
    return res.data;
  }

  Future<List<dynamic>> getMyVoices() async {
    final res = await api.get("/voice/me");
    return res.data;
  }
}
