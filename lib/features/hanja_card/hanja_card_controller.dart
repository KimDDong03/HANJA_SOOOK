import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/hanja_example.dart';
import '../../domain/models/stroke_asset.dart';

final hanjaCardProvider = FutureProvider.family<HanjaCardState, String>((
  ref,
  hanjaId,
) async {
  final repository = ref.watch(contentRepositoryProvider);
  final hanja = await repository.getHanjaById(hanjaId);
  final examples = await repository.getExamples(hanjaId);
  final strokeAsset = await repository.getStrokeAsset(hanjaId);
  return HanjaCardState(
    hanja: hanja,
    examples: examples,
    strokeAsset: strokeAsset,
  );
});

class HanjaCardState {
  const HanjaCardState({
    required this.hanja,
    required this.examples,
    required this.strokeAsset,
  });

  final HanjaCharacter? hanja;
  final List<HanjaExample> examples;
  final StrokeAsset? strokeAsset;
}
