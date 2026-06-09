import 'package:navio/services/groq_service.dart';

extension CareerTools on GroqService {
  Future<String?> convertFieldToJobTitle(String field) {
    return sendChat(
      model: "llama-3.1-8b-instant",
      systemPrompt:
          "Convert the given field of study into a concise job title. Respond with ONLY the job title.",
      userPrompt: field,
      maxTokens: 50,
    );
  }
}
