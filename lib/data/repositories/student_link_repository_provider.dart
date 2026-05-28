import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/student_link_repository.dart';
import '../local/app_database_provider.dart';
import 'student_link_repository_impl.dart';

final studentLinkRepositoryProvider = Provider<StudentLinkRepository>((ref) {
  return StudentLinkRepositoryImpl(ref.watch(appDatabaseProvider));
});
