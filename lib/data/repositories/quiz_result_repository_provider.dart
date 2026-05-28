import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/quiz_result_repository.dart';
import '../local/app_database_provider.dart';
import 'quiz_result_repository_impl.dart';

final quizResultRepositoryProvider = Provider<QuizResultRepository>((ref) {
  return QuizResultRepositoryImpl(ref.watch(appDatabaseProvider));
});
