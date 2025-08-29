import 'package:dio/dio.dart';

class ErrorMapper {
  static String toMessage(Object error) {
    try {
      final e = error;

      if (e is FormatException) return 'Invalid response format';
      // if (e is DioException) return e.message;
      return e.toString();
    } catch (_) {
      return 'Something went wrong';
    }
  }
}