import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voiceapp/core/api_client.dart';
import 'package:voiceapp/models/user.dart';

class AuthService {
  final api = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<UserModel> anonymousLogin(String username) async {
    final res = await api.post(
      "/auth/anonymous",
      data: {"username": username},
    );
    final token = res.data["token"];
    if (token != null) {
      await _storage.write(key: "token", value: token);
    }
    return UserModel.fromJson(res.data["user"]);
  }

  Future<UserModel> googleLogin(String idToken) async {
    final res = await api.post(
      "/auth/google",
      data: {"idToken": idToken},
    );
    final token = res.data["token"];
    if (token != null) {
      await _storage.write(key: "token", value: token);
    }
    return UserModel.fromJson(res.data["user"]);
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: "token");
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
  }
}
