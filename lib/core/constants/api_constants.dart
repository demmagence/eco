class ApiConstants {
  ApiConstants._();

  // Backend API (Node.js Local Server)
  static const String apiBaseUrl = 'http://localhost:3000/api';
  // For Android Emulator, use: 'http://10.0.2.2:3000/api'

  // Gemini AI (image analysis, daily tip, news)
  static const String geminiApiKey = 'AQ.Ab8RN6L5Cco91BLpu75s2pn59PZAzB_vB6FymagGA8qxnPCgwA';
  static const String geminiModel = 'gemini-3.5-flash';

  // Groq AI (Eco Assistant chatbot) — OpenAI-compatible chat completions
  static const String groqApiKey =
      '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';
  static const String groqModel = 'openai/gpt-oss-120b';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // OpenWeatherMap
  static const String owmApiKey = '9e9236e258d9bf2391fee7ef5865b5b6';
  static const String owmBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String owmWeatherEndpoint = '/weather';
  static const String owmAqiEndpoint = '/air_pollution';

  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
