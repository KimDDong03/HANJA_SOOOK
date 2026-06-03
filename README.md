# 한자쏘옥 Codex Starter

이 폴더는 **Codex가 판단하지 않고 구현만 하도록** 만들기 위한 프로젝트 시작 패키지입니다.
Flutter 앱 코드는 아직 구현하지 않고, 구현 기준/폴더 구조/DB 스키마/작업 티켓/AGENTS 지침을 먼저 고정합니다.

## 사용 방법

1. 이 폴더를 새 Git 저장소 루트로 둡니다.
2. Codex를 열고 루트의 `AGENTS.md`를 읽게 합니다.
3. Codex에게 아래 한 줄만 입력합니다.

```txt
구현 시작해
```

4. Codex는 `docs/06_CODEX_TASKS.md`의 Ticket 00부터 순서대로 구현해야 합니다.
5. 각 Ticket은 `flutter analyze`와 필요한 테스트를 통과하기 전까지 완료로 간주하지 않습니다.

## 앱 실행/빌드

앱을 실행하거나 빌드할 때는 루트의 `.env` 파일을 Dart define으로 반드시 전달합니다.

```txt
flutter run -d emulator-5554 --dart-define-from-file=.env
flutter build apk --debug --dart-define-from-file=.env
```

`.env`에는 `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `APP_ENV` 키가 있어야 합니다.
실제 `.env` 값은 커밋하지 말고, 키 이름은 `.env.example`을 기준으로 맞춥니다.

## 핵심 결정

- 앱: Flutter
- DB/Backend: Supabase
- 학교 데이터: `data/source/학교기본정보_2026년03월31일기준.csv` 기반 Supabase seed
- 상태관리: Riverpod
- 라우팅: go_router
- 모델: Freezed + json_serializable
- 로컬 캐시: Drift
- 획순: `StrokeEngine` 추상화 뒤에서 오픈소스/수동 데이터 교체 가능하게 구현
- 1차 MVP: 학생용 학습 체험 루프 중심

## 중요한 원칙

- UI 화면에서 Supabase를 직접 호출하지 않습니다.
- 화면에서 점수, XP, 획순 판정 로직을 직접 계산하지 않습니다.
- 모든 데이터 접근은 Repository Interface를 통해서만 합니다.
- 1차 MVP는 실서비스 전체 구축이 아니라 시연 가능한 학습 플로우 구현입니다.
