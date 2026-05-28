import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/learning_progress_repository.dart';
import '../local/app_database_provider.dart';
import 'learning_progress_repository_impl.dart';

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) {
    return LearningProgressRepositoryImpl(ref.watch(appDatabaseProvider));
  },
);
