import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/services/thinking_unit_image_service.dart';

void main() {
  test(
    'ThinkingUnitImageService returns sub-unit titles from image filenames',
    () {
      const service = ThinkingUnitImageService();

      expect(service.subUnitTitleForChapterKey('G3-U01-L01'), '첫 나라를 세운 단군');
      expect(service.subUnitTitleForChapterKey('G6-U08-L04'), '대한민국 첫 대통령 이승만');
    },
  );

  test('ThinkingUnitImageService builds display title with sub-unit title', () {
    const service = ThinkingUnitImageService();

    expect(
      service.displayTitleForChapterKey(
        chapterKey: 'G3-U01-L01',
        fallbackName: '초3 1단원 1. 나라를 세운 역사 인물',
      ),
      '초3 1단원 1. 첫 나라를 세운 단군',
    );
  });

  test('ThinkingUnitImageService falls back when a title is missing', () {
    const service = ThinkingUnitImageService();

    expect(
      service.displayTitleForChapterKey(
        chapterKey: 'custom',
        fallbackName: '기본 단원',
      ),
      '기본 단원',
    );
  });
}
