class ThinkingUnitImageService {
  const ThinkingUnitImageService();

  String? imageAssetPathForChapterKey(String chapterKey) {
    final parts = _parseChapterKey(chapterKey);
    if (parts == null) {
      return null;
    }
    return 'assets/images/thinking_units/g${parts.grade}/'
        'g${parts.grade}_u${parts.unit}_l${parts.lesson}.png';
  }

  String? subUnitTitleForChapterKey(String chapterKey) {
    return _subUnitTitles[chapterKey];
  }

  String displayTitleForChapterKey({
    required String chapterKey,
    required String fallbackName,
  }) {
    final parts = _parseChapterKey(chapterKey);
    final subUnitTitle = subUnitTitleForChapterKey(chapterKey);
    if (parts == null || subUnitTitle == null) {
      return fallbackName;
    }
    return '초${parts.grade} ${int.parse(parts.unit)}단원 '
        '${int.parse(parts.lesson)}. $subUnitTitle';
  }

  String? majorUnitKeyForChapterKey(String chapterKey) {
    final parts = _parseChapterKey(chapterKey);
    if (parts == null) {
      return null;
    }
    return 'G${parts.grade}-U${parts.unit}';
  }

  _ThinkingUnitKeyParts? _parseChapterKey(String chapterKey) {
    final match = RegExp(r'^G(\d+)-U(\d+)-L(\d+)$').firstMatch(chapterKey);
    if (match == null) {
      return null;
    }
    return _ThinkingUnitKeyParts(
      grade: match.group(1)!,
      unit: int.parse(match.group(2)!).toString().padLeft(2, '0'),
      lesson: int.parse(match.group(3)!).toString().padLeft(2, '0'),
    );
  }
}

class _ThinkingUnitKeyParts {
  const _ThinkingUnitKeyParts({
    required this.grade,
    required this.unit,
    required this.lesson,
  });

  final String grade;
  final String unit;
  final String lesson;
}

const _subUnitTitles = {
  'G3-U01-L01': '첫 나라를 세운 단군',
  'G3-U01-L02': '신라를 세운 박혁거세',
  'G3-U01-L03': '고구려를 세운 주몽',
  'G3-U01-L04': '백제를 세운 온조',
  'G3-U02-L01': '매일 노는 게으름뱅이',
  'G3-U02-L02': '탈을 쓴 게으름뱅이',
  'G3-U02-L03': '후회하며 반성하는 게으름뱅이',
  'G3-U02-L04': '소에서 사람이 된 게으름뱅이',
  'G3-U03-L01': '백제의 전성기 근초고왕',
  'G3-U03-L02': '광개토대왕',
  'G3-U03-L03': '신라의전성기 진흥왕',
  'G3-U03-L04': '을지문덕',
  'G3-U04-L01': '형제들과 다른 반쪽이',
  'G3-U04-L02': '힘이 센 반쪽이',
  'G3-U04-L03': '부자 영감과 내기하는 반쪽이',
  'G3-U04-L04': '건강한 사내가 된 반쪽이',
  'G3-U05-L01': '백제의 마지막 왕 의자왕',
  'G3-U05-L02': '연개소문',
  'G3-U05-L03': '동해에묻힌문무왕',
  'G3-U05-L04': '발해를 세운 대조영',
  'G3-U06-L01': '냄새 값을 달라는 영감님',
  'G3-U06-L02': '부자 영감을 찾아간 아들',
  'G3-U06-L03': '화가 난 부자 영감',
  'G3-U06-L04': '냄새 값을 소릿값으로 갚는 아들',
  'G3-U07-L01': '비단을 잃어버린 비단 장수',
  'G3-U07-L02': '죄인이 된 망주석',
  'G3-U07-L03': '비단을 사는 사람들',
  'G3-U07-L04': '비단을 찾은 비단 장수',
  'G4-U01-L01': '사회개혁을꿈꾼최치원',
  'G4-U01-L02': '후백제를세운견훤',
  'G4-U01-L03': '후고구려를세운궁예',
  'G4-U01-L04': '고려를세운왕건',
  'G4-U02-L01': '열심히일하는나무꾼',
  'G4-U02-L02': '금도끼를가지고온산신령',
  'G4-U02-L03': '칭찬과선물을받은나무꾼',
  'G4-U02-L04': '야단맞은욕심많은나무꾼',
  'G4-U03-L01': '외교전략으로나라를지킨서희',
  'G4-U03-L02': '목숨바쳐나라를지킨양규',
  'G4-U03-L03': '귀주대첩에서거란을물리친강감찬',
  'G4-U03-L04': '동북9성을세운윤관',
  'G4-U04-L01': '마을소문과삼년고개',
  'G4-U04-L02': '삼년고개에서넘어진할아버지',
  'G4-U04-L03': '할아버지의고민을풀어주는순돌이',
  'G4-U04-L04': '장수고개가된삼년고개',
  'G4-U05-L01': '몽골을물리친김윤후',
  'G4-U05-L02': '화약무기로왜구를물리친최무선',
  'G4-U05-L03': '황금보기를돌같이한최영장군',
  'G4-U05-L04': '이몸이죽고죽어정몽주',
  'G4-U06-L01': '마음씨착한혹부리영감님',
  'G4-U06-L02': '도깨비를만난혹부리영감',
  'G4-U06-L03': '혹과바꾼금은보화',
  'G4-U06-L04': '욕심쟁이영감과도깨비의분노',
  'G4-U07-L01': '임금님의선물',
  'G4-U07-L02': '지혜의띠를가진까치',
  'G4-U07-L03': '참새와파리의다툼',
  'G4-U07-L04': '까치의판결',
  'G5-U01-L01': '병에 걸린 용왕님',
  'G5-U01-L02': '토끼를 만난 자라',
  'G5-U01-L03': '용궁에 들어간 토끼',
  'G5-U01-L04': '숲으로 달아난 토끼',
  'G5-U02-L01': '조선을 건국한 이성계',
  'G5-U02-L02': '조선의 설계자 정도전',
  'G5-U02-L03': '백성을 자식처럼 사랑한 세종대왕',
  'G5-U02-L04': '백두산 호랑이 김종서',
  'G5-U03-L01': '떡을 원하는 호랑이',
  'G5-U03-L02': '어머니로 변장한 호랑이',
  'G5-U03-L03': '나무 위로 올라간 오누이',
  'G5-U03-L04': '해님과 달님이 된 오누이',
  'G5-U04-L01': '조선 시대 발명가 장영실',
  'G5-U04-L02': '여류 예술가 신사임당',
  'G5-U04-L03': '조선의 대성리학자 이황',
  'G5-U04-L04': '십만 양병설을 주장한 이이',
  'G5-U05-L01': '바른 말만 하는 이방',
  'G5-U05-L02': '고민하는 이방',
  'G5-U05-L03': '문제를 슬기롭게 해결하는 이방 아들',
  'G5-U05-L04': '사또를 이긴 지혜로운 이방 아들',
  'G5-U06-L01': '필사즉생 이순신',
  'G5-U06-L02': '홍의 장군 곽재우',
  'G5-U06-L03': '진주 대첩 김시민',
  'G5-U06-L04': '행주 대첩 권율',
  'G5-U07-L01': '소금을 팔러 간 소금 장수 아들',
  'G5-U07-L02': '혼인 잔치를 망친 소금 장수 아들',
  'G5-U07-L03': '때와 장소를 구별 못하는 소금 장수 아들',
  'G5-U07-L04': '끝까지 엉뚱하게 행동하는 소금 장수 아들',
  'G5-U08-L01': '개혁 정치를 펼친 영조와 정조',
  'G5-U08-L02': '조선의 여성 사업가 김만덕',
  'G5-U08-L03': '개혁과 배움의 길을 걸은 정약용',
  'G5-U08-L04': '연암 박지원 글로 세상을 바꾸다',
  'G6-U01-L01': '마을에 나타난 호랑이',
  'G6-U01-L02': '호랑이보다 무서운 곶감',
  'G6-U01-L03': '무서워하는 호랑이',
  'G6-U01-L04': '안도의 숨을 쉬는 호랑이',
  'G6-U02-L01': '나라를 지키려 한 흥선대원군',
  'G6-U02-L02': '새로운 세상을 꿈꾼 박규수',
  'G6-U02-L03': '조선 말 의병 지도자 최익현',
  'G6-U02-L04': '갑신정변 김옥균',
  'G6-U03-L01': '재주가 특이한 네 형제',
  'G6-U03-L02': '네 형제가 백성들을 위해 나서다',
  'G6-U03-L03': '벌을 받는 형제들',
  'G6-U03-L04': '벌을 이겨내는 형제들',
  'G6-U04-L01': '녹두장군 전봉준',
  'G6-U04-L02': '대한제국을 수립한 고종',
  'G6-U04-L03': '나라 사랑을 실천한 서재필',
  'G6-U04-L04': '백성을 지킨 의병장 신돌석',
  'G6-U05-L01': '잉어를 살려 준 할아버지',
  'G6-U05-L02': '요술 구슬을 얻은 할아버지',
  'G6-U05-L03': '구슬을 찾아오는 개와 고양이',
  'G6-U05-L04': '안방의 고양이와 마당의 개',
  'G6-U06-L01': '최초의 여성 의병장 윤희순',
  'G6-U06-L02': '동양 평화를 꿈꾼 독립운동가 안중근',
  'G6-U06-L03': '민족의 교육자 남강 이승훈',
  'G6-U06-L04': '열일곱 소녀 유관순 나라를 위해 살다',
  'G6-U07-L01': '달라도 너무 다른 형제',
  'G6-U07-L02': '형편이 더욱 어려워진 흥부 가족',
  'G6-U07-L03': '제비 덕에 부자가 된 흥부',
  'G6-U07-L04': '용서하고 화해하는 흥부',
  'G6-U08-L01': '민족의 힘을 키우자고 주장한 안창호',
  'G6-U08-L02': '한국사를 잊지 말자 박은식',
  'G6-U08-L03': '독립의식을 노래한 애국 시인 윤동주',
  'G6-U08-L04': '대한민국 첫 대통령 이승만',
};
