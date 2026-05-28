import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/class_room_repository.dart';
import '../local/app_database_provider.dart';
import 'class_room_repository_impl.dart';

final classRoomRepositoryProvider = Provider<ClassRoomRepository>((ref) {
  return ClassRoomRepositoryImpl(ref.watch(appDatabaseProvider));
});
