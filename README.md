# 한자쏘옥

초등학생용 한자 학습 Flutter 앱입니다. Supabase 기반 로그인/콘텐츠, Riverpod 상태관리, go_router 라우팅, Drift 로컬 캐시 구조로 MVP 학습 플로우를 구현합니다.

## 개발 기준

- 구현 범위와 제품 정책은 `docs/02_PRODUCT_SPEC.md`, `docs/06_CODEX_TASKS.md`, `AGENTS.md`를 따릅니다.
- 화면은 Supabase나 점수 계산을 직접 처리하지 않고 controller/service/repository 계층을 통해 동작합니다.
- 티켓 완료 기준은 `flutter analyze`, 관련 테스트, 도달 가능한 라우트, 빈/로딩/오류 상태 처리입니다.

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
