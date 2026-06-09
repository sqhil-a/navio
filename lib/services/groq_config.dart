class GroqConfig {
  static const apiKey = String.fromEnvironment('GROQ_API_KEY');

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
