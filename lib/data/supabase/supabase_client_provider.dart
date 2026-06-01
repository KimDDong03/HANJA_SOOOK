import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/env.dart';
import '../../core/errors/app_exception.dart';
import 'supabase_session_storage.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final client = _supabaseClient;
  if (client == null) {
    throw const AppException(
      code: AppExceptionCode.unknown,
      message: 'Supabase client has not been initialized.',
    );
  }
  return client;
});

SupabaseClient? _supabaseClient;

Future<void> initializeSupabase() async {
  if (!AppEnv.hasSupabaseConfig) {
    throw AppException(
      code: AppExceptionCode.validation,
      message: AppEnv.missingSupabaseConfigMessage,
    );
  }

  final supabase = await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      localStorage: SecureSupabaseSessionStorage(),
    ),
  );
  _supabaseClient = supabase.client;
}
