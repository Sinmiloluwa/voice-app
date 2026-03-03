import 'dart:convert';
import 'dart:typed_data';

import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/user.dart';

class UserService {
  final api = ApiClient().dio;

  Future<Uint8List> getProfileQrCode() async {
    final res = await api.get('/user/profile/qr');
    final raw = res.data is String ? res.data as String : res.data['qr'] as String;
    // Strip data URI prefix if present (e.g. "data:image/png;base64,...")
    final base64Str = raw.contains(',') ? raw.split(',').last : raw;
    return base64Decode(base64Str);
  }

  Future<void> followUser(String userId) async {
    await api.post("/user/follow/$userId");
  }

  Future<void> unfollowUser(String userId) async {
    await api.delete("/user/follow/$userId");
  }

  Future<List<UserModel>> getFollowing() async {
    final res = await api.get("/user/following");
    return (res.data as List).map((e) => UserModel.fromJson(e)).toList();
  }
}
