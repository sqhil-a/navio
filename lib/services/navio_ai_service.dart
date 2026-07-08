import 'package:dio/dio.dart';

class NavioAiService {
  static const String _baseUrl =
      'https://navio-worker.naviopathways.workers.dev';

  static const String _appToken = 'navio-pathways-v1';
  static const String _model = 'openai/gpt-oss-20b';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'X-Navio-App': _appToken,
        'X-Navio-User': 'test-user-1',
      },
    ),
  );

  Future<String> sendPrompt(String prompt) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': _model,
          'prompt': prompt,
          'system':
              'You are Navio Pathways, a helpful career planning assistant for students. Give clear, encouraging, age-appropriate guidance.',
        },
      );

      final data = response.data;

      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }

      throw Exception('Invalid response from backend.');
    } on DioException catch (e) {
      final error = e.response?.data;

      if (error is Map) {
        final message = error['message'] ?? error['error'];
        if (message != null) {
          throw Exception(message.toString());
        }
      }

      throw Exception('Could not connect to Navio Pathways AI.');
    } catch (_) {
      throw Exception('Something went wrong.');
    }
  }
}
