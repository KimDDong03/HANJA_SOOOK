import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/pending_sync_repository.dart';
import '../local/app_database_provider.dart';
import 'pending_sync_repository_impl.dart';

final pendingSyncRepositoryProvider = Provider<PendingSyncRepository>((ref) {
  return PendingSyncRepositoryImpl(ref.watch(appDatabaseProvider));
});
