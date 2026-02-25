import 'dart:io';
import 'package:dio/dio.dart';
import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/feed_response.dart';
import 'package:voiceapp/models/voice_post.dart';

class Category {
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['name'] ?? '',
      );
}

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
    required File audio,
    required int duration,
    String? category,
  }) async {
    final formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(
        audio.path,
        filename: "voice.m4a",
      ),
      "duration": duration,
      if (category != null) "category": category,
    });

    await api.post("/voice/upload", data: formData);
  }

  Future<List<Category>> getCategories() async {
    final res = await api.get("/categories");
    final list = res.data is List
        ? res.data
        : (res.data["data"] ?? res.data["categories"] ?? []);
    return (list as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FeedResponse> getFeed({FeedType type = FeedType.forYou}) async {
    final res = await api.get("/voice/feed?type=${type.value}");
    if (res.data is List) {
      return FeedResponse(
        voices: (res.data as List).map((e) => VoicePost.fromJson(e)).toList(),
        users: [],
        tags: [],
      );
    }
    return FeedResponse.fromJson(res.data);
  }

  Future<void> addReaction(String postId, String emoji) async {
    await api.post("/voice/$postId/react", data: {"type": emoji});
  }

  Future<void> removeReaction(String postId) async {
    await api.delete("/voice/$postId/react");
  }

  Future<List<VoicePost>> getMyUploads() async {
    final res = await api.get("/voice/my-uploads");
    final list = res.data is List ? res.data : (res.data["data"] ?? res.data["voices"] ?? []);
    return (list as List).map((e) => VoicePost.fromJson(e)).toList();
  }

  Future<List<VoicePost>> searchPost(String query) async {
    final res = await api.get("/search", queryParameters: {"q": query});
    final data = res.data;
    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data["posts"]?["voices"] ?? data["voices"] ?? data["data"] ?? [];
    } else {
      list = [];
    }
    return list.map((e) => VoicePost.fromJson(e as Map<String, dynamic>)).toList();
  }
}