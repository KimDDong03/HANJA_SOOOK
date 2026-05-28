import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/school_repository.dart';
import '../supabase/supabase_client_provider.dart';
import 'school_repository_impl.dart';

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  return SchoolRepositoryImpl(ref.watch(supabaseClientProvider));
});
