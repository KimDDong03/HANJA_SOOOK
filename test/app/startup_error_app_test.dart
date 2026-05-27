import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/startup_error_app.dart';
import 'package:hanja_soook/core/errors/app_exception.dart';
import 'package:hanja_soook/data/supabase/supabase_client_provider.dart';

void main() {
  test(
    'initializeSupabase gives clear error when dart defines are missing',
    () {
      expect(
        initializeSupabase,
        throwsA(
          isA<AppException>().having(
            (error) => error.userMessage,
            'userMessage',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    },
  );

  testWidgets('StartupErrorApp renders a user-facing setup error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const StartupErrorApp(
        message:
            'Supabase 설정이 없습니다. SUPABASE_URL과 SUPABASE_ANON_KEY를 --dart-define으로 전달해주세요.',
      ),
    );

    expect(find.text('앱 설정을 확인해주세요'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
    expect(find.textContaining('SUPABASE_ANON_KEY'), findsOneWidget);
  });
}
