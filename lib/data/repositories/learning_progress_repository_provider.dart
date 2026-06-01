import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/learning_progress_repository.dart';
import '../local/app_database_provider.dart';
import '../supabase/supabase_client_provider.dart';
import 'learning_progress_repository_impl.dart';
import 'pending_sync_repository_provider.dart';

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) {
    return LearningProgressRepositoryImpl(
      ref.watch(appDatabaseProvider),
      remoteClient: ref.watch(supabaseClientProvider),
      pendingSyncRepository: ref.watch(pendingSyncRepositoryProvider),
    );
  },
);
