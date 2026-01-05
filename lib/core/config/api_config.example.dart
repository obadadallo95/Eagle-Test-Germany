/// ملف مثال لـ API Keys
/// 
/// ⚠️ **تعليمات:**
/// 1. انسخ هذا الملف إلى api_config.dart
/// 2. ضع API Key الخاص بك في api_config.dart
/// 3. لا ترفع api_config.dart إلى Git (موجود في .gitignore)
class ApiConfig {
  // Groq API Key
  // للحصول على API Key: https://console.groq.com/keys
  static const String groqApiKey = 'YOUR_GROQ_API_KEY_HERE';
  
  // Model: llama-3.1-8b-instant (سريع ومجاني) أو mixtral-8x7b-32768 (أكثر دقة)
  static const String groqModel = 'llama-3.1-8b-instant';
}

