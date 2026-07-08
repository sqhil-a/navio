import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AiRateLimitException implements Exception {
  final String message;

  AiRateLimitException([
    this.message = "AI is temporarily unavailable. Please wait a minute and try again.",
  ]);

  @override
  String toString() => message;
}

class GroqService {
  static const String _baseUrl =
      'https://navio-worker.naviopathways.workers.dev';

  static const String _appToken = 'navio-pathways-v1';

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'X-Navio-App': _appToken,
      },
    ),
  );

  /// Kept for compatibility with your existing code.
  /// The API key is no longer used in the app.
  GroqService({String? apiKey});

  /// Single-turn chat completion.
  Future<String?> sendChat({
    required String model,
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.2,
    int maxTokens = 100,
  }) async {
    return _post(
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    );
  }

  /// Multi-turn chat completion.
  /// [history] is a list of {"role": "user"/"assistant", "content": "..."} maps.
  Future<String?> sendChatMultiTurn({
    required String model,
    required String systemPrompt,
    required List<Map<String, String>> history,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    return _post(
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      messages: [
        {'role': 'system', 'content': systemPrompt},
        ...history,
      ],
    );
  }

  Future<String?> _post({
    required String model,
    required double temperature,
    required int maxTokens,
    required List<Map<String, String>> messages,
  }) async {
    try {
      final response = await dio.post(
        '/api/chat',
        data: {
          'model': model,
          'temperature': temperature,
          'maxTokens': maxTokens,
          'messages': messages,
        },
      );

      final data = response.data;

      if (data is Map && data['message'] is String) {
        return (data['message'] as String).trim();
      }

      debugPrint('Worker returned invalid response: $data');
      return null;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 429) {
          final message = data is Map && data["message"] is String
              ? data["message"] as String
              : "Please wait a minute before trying again.";

          throw AiRateLimitException(message);
        }

        debugPrint('Navio Worker ERROR: ${e.response?.data ?? e.message}');
        return null;
      }
  }
}