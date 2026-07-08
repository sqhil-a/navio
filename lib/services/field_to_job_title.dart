import 'package:navio/services/groq_service.dart';

extension CareerTools on GroqService {
  Future<String?> convertFieldToJobTitle(String field) {
    return sendChat(
      model: "openai/gpt-oss-20b",
      systemPrompt:
          "Convert the given field of study into a concise job title. Respond with ONLY the job title.",
      userPrompt: field,
      maxTokens: 50,
    );
  }
}
