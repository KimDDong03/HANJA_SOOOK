import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/app.dart';
import 'package:hanja_soook/app/router.dart';
import 'package:hanja_soook/core/constants/route_paths.dart';

void main() {
  testWidgets('ticket 00 routes render placeholders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HanjaSoookApp()));

    expect(find.text('한자쏘옥'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('학교와 학생 정보를 입력해요'), findsOneWidget);

    await tester.tap(find.text('임시로 홈으로 이동'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 한자를 시작해요'), findsOneWidget);

    final routeChecks = <String, String>{
      '한자 카드': '한자 ID: demo-hanja',
      '따라쓰기': '한자 ID: demo-hanja',
      '퀴즈': '10문제 4지선다 퀴즈 화면 자리입니다.',
      '게임': '뜻을 보고 맞는 한자를 고르는 게임 화면 자리입니다.',
      '결과': '점수, 별점, XP 결과 화면 자리입니다.',
      '성장': '레벨, XP, 배지 화면 자리입니다.',
      '교사 미리보기': '시연용 학급 현황 화면 자리입니다.',
    };

    for (final entry in routeChecks.entries) {
      appRouter.go(RoutePaths.home);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
