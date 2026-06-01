import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/features/writing/writing_controller.dart';

void main() {
  test('WritingState treats invalid stroke paths as missing guide data', () {
    final state = WritingState(
      hanja: null,
      examples: const [],
      strokeAsset: const StrokeAsset(character: '一', svgPaths: ['M 10 10 L']),
    );

    expect(state.svgPaths, isEmpty);
    expect(state.hasStrokeGuide, isFalse);
  });
}
