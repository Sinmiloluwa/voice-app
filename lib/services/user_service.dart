import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/user.dart';

class UserService {
  final api = ApiClient().dio;

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
