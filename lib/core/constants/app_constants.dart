class AppConstants {
  // Keys must be passed via --dart-define at build time:
  // flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // 🔧 FIX: use throw instead of assert so this works in release mode too
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        '❌ Supabase keys are not set.\n'
        'Run with:\n'
        '  flutter run \\\n'
        '    --dart-define=SUPABASE_URL=https://xxxx.supabase.co \\\n'
        '    --dart-define=SUPABASE_ANON_KEY=eyJ...\n',
      );
    }
  }
}
