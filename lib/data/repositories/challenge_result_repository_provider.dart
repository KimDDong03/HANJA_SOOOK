import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/challenge_result_repository.dart';
import '../local/app_database_provider.dart';
import '../supabase/supabase_client_provider.dart';
import 'challenge_result_repository_impl.dart';
import 'pending_sync_repository_provider.dart';

final challengeResultRepositoryProvider = Provider<ChallengeResultRepository>((
  ref,
) {
  return ChallengeResultRepositoryImpl(
    ref.watch(appDatabaseProvider),
    remoteClient: ref.watch(supabaseClientProvider),
    pendingSyncRepository: ref.watch(pendingSyncRepositoryProvider),
  );
});
