class ApiConstants {
  ApiConstants._();

  // Backend API (Node.js Deployed Server on Vercel)
  static const String apiBaseUrl = 'https://eco-beta-nine.vercel.app/api';
  // For Android Emulator, use: 'http://10.0.2.2:3000/api'

  // Gemini AI (image analysis, daily tip, news)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiModel = 'gemini-3.5-flash';

  // Groq AI (Eco Assistant chatbot) — OpenAI-compatible chat completions
  static const String groqApiKey =
      'YOUR_GROQ_API_KEY';
  static const String groqModel = 'openai/gpt-oss-120b';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // OpenWeatherMap
  static const String owmApiKey = 'YOUR_OWM_API_KEY';
  static const String owmBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String owmWeatherEndpoint = '/weather';
  static const String owmAqiEndpoint = '/air_pollution';

  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
