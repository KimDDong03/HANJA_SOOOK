import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/writing/widgets/hanja_free_writing_canvas.dart';
import 'package:hanja_soook/features/writing/widgets/hanja_writing_practice_canvas.dart';

void main() {
  testWidgets('free writing icon-only controls expose tooltips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 260,
              height: 340,
              child: HanjaFreeWritingCanvas(
                expectedStrokeCount: 3,
                canvasExtent: 220,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('한 획 지우기'), findsOneWidget);
    expect(find.byTooltip('모두 지우기'), findsOneWidget);
  });

  testWidgets('guided writing icon-only reset control exposes tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 340,
              child: HanjaWritingPracticeCanvas(
                svgPaths: ['M 10 10 L 90 10'],
                canvasExtent: 220,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('다시 시작'), findsOneWidget);
    expect(find.text('획순 보기'), findsOneWidget);
  });
}
