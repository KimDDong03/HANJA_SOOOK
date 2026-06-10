import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/env.dart';
import '../../data/local/app_database_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_diagnostics.dart';
import 'learning_progress_controller.dart';

final demoReviewFocusSeedEnabledProvider = Provider<bool>((ref) {
  return AppEnv.hasSupabaseConfig;
});

final demoReviewFocusSeedControllerProvider =
    Provider<DemoReviewFocusSeedController>(DemoReviewFocusSeedController.new);

class DemoReviewFocusSeedController {
  DemoReviewFocusSeedController(this._ref);

  final Ref _ref;
  final Map<String, Future<void>> _seedFuturesByStudent = {};

  Future<void> ensureSeeded({required List<HanjaCharacter> items}) async {
    if (!_ref.read(demoReviewFocusSeedEnabledProvider)) {
      return;
    }

    final candidates = items
        .where((item) => item.id.trim().isNotEmpty)
        .toList(growable: false);
    if (candidates.length < 4) {
      return;
    }

    final studentKey = currentStudentKey(_ref);
    final existingFuture = _seedFuturesByStudent[studentKey];
    if (existingFuture != null) {
      await existingFuture;
      return;
    }

    final seedFuture = _seed(studentKey: studentKey, candidates: candidates);
    _seedFuturesByStudent[studentKey] = seedFuture;
    try {
      await seedFuture;
    } catch (_) {
      _seedFuturesByStudent.remove(studentKey);
      rethrow;
    }
  }

  Future<void> _seed({
    required String studentKey,
    required List<HanjaCharacter> candidates,
  }) async {
    final database = _ref.read(appDatabaseProvider);
    final reviewItems = candidates.take(4).toList();
    final focusItems = candidates.skip(4).take(3).toList();
    final seededItemsById = <String, HanjaCharacter>{
      for (final item in [...reviewItems, ...focusItems]) item.id: item,
    };

    for (final item in seededItemsById.values) {
      await database.markHanjaCompleted(
        studentKey: studentKey,
        learningDate: _demoSeedLearningDate,
        hanjaId: item.id,
        completedAt: _demoSeedCompletedAt,
      );
    }

    for (var index = 0; index < focusItems.length; index += 1) {
      final item = focusItems[index];
      final weaknessType =
          _demoWeaknessTypes[index % _demoWeaknessTypes.length];
      final existing = await database.getHanjaWeakness(
        studentKey: studentKey,
        hanjaId: item.id,
        weaknessType: weaknessType.storageValue,
      );
      if (existing != null) {
        continue;
      }
      final now = DateTime.now();
      await database.upsertHanjaWeakness(
        studentKey: studentKey,
        hanjaId: item.id,
        weaknessType: weaknessType.storageValue,
        score: 7 - index,
        status: HanjaWeaknessStatus.active.storageValue,
        mistakeCount: 2,
        successStreak: 0,
        lastEventAt: now.subtract(Duration(minutes: index)),
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}

const _demoSeedLearningDate = '20250601';
final _demoSeedCompletedAt = DateTime(2025, 6, 1, 9);

const _demoWeaknessTypes = [
  HanjaWeaknessType.hanjaRecognition,
  HanjaWeaknessType.hunMeaning,
  HanjaWeaknessType.writing,
];
