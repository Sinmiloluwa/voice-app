import 'package:voiceapp/core/api_client.dart';

class AuthService {
  final api = ApiClient().dio;

  Future<Map<String, dynamic>> anonymousLogin(String username) async {
    final res = await api.post(
      "/auth/anonymous",
      data: {"username": username},
    );
    return res.data;
  }
}