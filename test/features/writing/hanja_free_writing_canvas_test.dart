import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/writing/widgets/hanja_free_writing_canvas.dart';

void main() {
  testWidgets('free writing canvas records and removes strokes', (
    tester,
  ) async {
    var changedStrokeCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            child: HanjaFreeWritingCanvas(
              expectedStrokeCount: 10,
              onStrokesChanged: (strokes) {
                changedStrokeCount = strokes.length;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('0 / 10'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('hanja-free-writing-canvas-input')),
      const Offset(60, 40),
    );
    await tester.pump();

    expect(find.text('1 / 10'), findsOneWidget);
    expect(changedStrokeCount, 1);

    await tester.tap(find.byIcon(Icons.undo));
    await tester.pump();

    expect(find.text('0 / 10'), findsOneWidget);
    expect(changedStrokeCount, 0);
  });
}
