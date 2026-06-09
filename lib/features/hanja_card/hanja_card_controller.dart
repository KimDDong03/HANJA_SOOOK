import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/hanja_example.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/svg_path_parser.dart';

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

  List<String> get svgPaths {
    final paths = strokeAsset?.svgPaths?.whereType<String>().toList();
    if (paths == null || paths.isEmpty) {
      return const [];
    }
    final validPaths = <String>[];
    for (final path in paths) {
      if (path.trim().isEmpty) {
        continue;
      }
      if (SvgPathParser.tryParse(path) == null) {
        return const [];
      }
      validPaths.add(path);
    }
    return validPaths;
  }

  bool get hasStrokeGuide => svgPaths.isNotEmpty;
}
