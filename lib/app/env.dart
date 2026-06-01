import '../core/constants/app_constants.dart';

class AppEnv {
  const AppEnv._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: AppConstants.appEnvDefault,
  );

  static String get normalizedAppEnv => appEnv.trim().toLowerCase();

  static bool get isDemo => normalizedAppEnv == 'demo';

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get missingSupabaseConfigMessage {
    final baseMessage =
        'Supabase 설정이 없습니다. SUPABASE_URL과 SUPABASE_ANON_KEY를 --dart-define으로 전달해주세요.';
    if (!isDemo) {
      return baseMessage;
    }
    return '$baseMessage demo 환경도 학교 검색과 익명 로그인을 위해 Supabase 설정이 필요합니다.';
  }
}
