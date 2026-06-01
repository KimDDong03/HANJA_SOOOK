import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/settings/settings_screen.dart';

void main() {
  testWidgets('teacher settings explains local demo storage accurately', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsScreen(role: 'teacher')),
      ),
    );

    expect(find.text('미리보기 도구'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('미리보기에서 만든 반 코드는 이 기기에 데모 데이터로 저장돼요. 실제 과제 배포나 알림은 실행되지 않아요.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('미리보기에서 만든 반 코드는 이 기기에 데모 데이터로 저장돼요. 실제 과제 배포나 알림은 실행되지 않아요.'),
      findsOneWidget,
    );
  });
}
