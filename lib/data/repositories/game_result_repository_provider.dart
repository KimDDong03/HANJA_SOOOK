import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/game_result_repository.dart';
import '../local/app_database_provider.dart';
import 'game_result_repository_impl.dart';

final gameResultRepositoryProvider = Provider<GameResultRepository>((ref) {
  return GameResultRepositoryImpl(ref.watch(appDatabaseProvider));
});
