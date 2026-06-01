import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/env.dart';

void main() {
  group('AppEnv', () {
    test('defaults to demo and explains missing Supabase config', () {
      expect(AppEnv.normalizedAppEnv, 'demo');
      expect(AppEnv.isDemo, isTrue);
      expect(AppEnv.hasSupabaseConfig, isFalse);
      expect(
        AppEnv.missingSupabaseConfigMessage,
        contains('demo 환경도 학교 검색과 익명 로그인을 위해 Supabase 설정이 필요합니다.'),
      );
    });
  });
}
