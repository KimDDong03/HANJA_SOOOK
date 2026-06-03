import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/learning_diagnostics_repository.dart';
import '../local/app_database_provider.dart';
import '../supabase/supabase_client_provider.dart';
import 'learning_diagnostics_repository_impl.dart';
import 'pending_sync_repository_provider.dart';

final learningDiagnosticsRepositoryProvider =
    Provider<LearningDiagnosticsRepository>((ref) {
      return LearningDiagnosticsRepositoryImpl(
        ref.watch(appDatabaseProvider),
        remoteClient: ref.watch(nullableSupabaseClientProvider),
        pendingSyncRepository: ref.watch(pendingSyncRepositoryProvider),
      );
    });
