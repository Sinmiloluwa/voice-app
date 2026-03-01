import 'package:dio/dio.dart';

String extractApiError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
  }
  return 'Something went wrong. Please try again.';
}
