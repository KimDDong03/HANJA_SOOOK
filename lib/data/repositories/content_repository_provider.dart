import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/content_repository.dart';
import '../local/content_seed_data_source.dart';
import 'content_repository_impl.dart';

final contentSeedDataSourceProvider = Provider<ContentSeedDataSource>((ref) {
  return ContentSeedDataSource();
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(ref.watch(contentSeedDataSourceProvider));
});
