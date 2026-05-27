import '../core/constants/app_constants.dart';

class AppEnv {
  const AppEnv._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: AppConstants.appEnvDefault,
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
