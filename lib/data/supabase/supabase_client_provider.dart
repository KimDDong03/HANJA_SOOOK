import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/env.dart';
import '../../core/errors/app_exception.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

Future<void> initializeSupabase() async {
  if (!AppEnv.hasSupabaseConfig) {
    throw const AppException(
      code: AppExceptionCode.validation,
      message:
          'Supabase 설정이 없습니다. SUPABASE_URL과 SUPABASE_ANON_KEY를 --dart-define으로 전달해주세요.',
    );
  }

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
}
