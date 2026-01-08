/// -----------------------------------------------------------------
/// 🔑 ENVIRONMENT CONFIGURATION / UMWELTKONFIGURATION / إعدادات البيئة
/// -----------------------------------------------------------------
/// Centralized configuration for API keys and environment variables.
/// This file should be kept secure and not committed to version control
/// with sensitive production keys.
/// -----------------------------------------------------------------
class EnvConfig {
  // Supabase Configuration
  // These keys are safe to expose in client-side code (they are public keys)
  static const String supabaseUrl = 'https://juhvrsiubbqgluauohfx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1aHZyc2l1YmJxZ2x1YXVvaGZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3Mzc1MTQsImV4cCI6MjA4MzMxMzUxNH0.DSW_kpNj8oQPb92VngS6BO9Nq7EGo2eWm0VtzE7jB5g';

  // Private constructor to prevent instantiation
  EnvConfig._();
}

