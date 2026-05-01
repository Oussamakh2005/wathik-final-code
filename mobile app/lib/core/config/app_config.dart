/// API Configuration
/// Set your API keys here
class AppConfig {
  // ========== OPENROUTER API ==========
  // Get your API key from: https://openrouter.ai/keys
  // Format: sk-or-v1-xxxxx...
  static const String openRouterApiKey = 'sk-or-v1-YOUR_API_KEY_HERE';

  // ========== OPENROUTER SETTINGS ==========
  static const String openRouterModel = 'qwen/qwen3-coder:free';
  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // ========== OTHER APIs ==========
  static const String invoiceProcessingApiUrl = 'https://api.wathik.amara57.com/api';

  // ========== DEBUG FLAGS ==========
  static const bool enableDebugLogging = true;
  static const bool useHardcodedApiKey = false; // Set to true to use static key above
}
