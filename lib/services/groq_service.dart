import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:navio/services/groq_config.dart';

class GroqService {
  final Dio dio = Dio();
  final String apiKey;

  GroqService({String? apiKey}) : apiKey = apiKey ?? GroqConfig.apiKey;

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
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userPrompt},
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
        {"role": "system", "content": systemPrompt},
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
    const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";
    if (apiKey.trim().isEmpty) {
      debugPrint(
        "Groq API key is missing. Pass --dart-define=GROQ_API_KEY=...",
      );
      return null;
    }

    try {
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": model,
          "temperature": temperature,
          "max_completion_tokens": maxTokens,
          "messages": messages,
        },
      );
      return response.data["choices"][0]["message"]["content"]?.trim();
    } catch (e) {
      debugPrint("Groq ERROR: $e");
      return null;
    }
  }
}
