# 01. Development Architecture

## 핵심 원칙

이 프로젝트는 빠른 MVP와 장기 유지보수를 동시에 만족해야 한다.
그러므로 화면 중심으로 빨리 만들되, 데이터 접근과 비즈니스 로직은 반드시 분리한다.

## 계층 구조

```txt
lib/
  app/                  # 앱 초기화, 라우터, 테마, env
  core/                 # 공통 위젯, 유틸, 에러, 상수
  domain/               # 순수 도메인 모델, repository interface, service
  data/                 # Supabase/Drift/asset 구현체
  features/             # 기능별 화면과 controller
```

## 의존성 방향

```txt
features/*/screen
→ features/*/controller
→ domain/services
→ domain/repositories
→ data/repositories
→ data/supabase or data/local
```

## 금지 규칙

- `features/*/screen.dart`에서 `Supabase.instance.client` 사용 금지
- `features/*/screen.dart`에서 raw `Map<String, dynamic>` 처리 금지
- `features/*/screen.dart`에서 XP/레벨/점수/획순 판정 계산 금지
- `domain/`에서 Flutter widget import 금지
- `data/`에서 feature screen import 금지
- `stroke_order_animator` 직접 import는 adapter 내부에서만 허용

## Folder Structure

```txt
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
    env.dart

  core/
    constants/
      app_constants.dart
      route_paths.dart
    errors/
      app_exception.dart
      failure.dart
    utils/
      date_time_utils.dart
      score_utils.dart
      hanja_utils.dart
    widgets/
      app_button.dart
      app_card.dart
      app_loading.dart
      app_error_view.dart

  domain/
    models/
      school.dart
      app_user_profile.dart
      hanja_character.dart
      hanja_example.dart
      quiz_question.dart
      stroke_asset.dart
      learning_session.dart
      writing_attempt.dart
      learning_result.dart
      growth_state.dart
      xp_event.dart
      badge.dart
    repositories/
      auth_repository.dart
      school_repository.dart
      content_repository.dart
      learning_repository.dart
      progress_repository.dart
      asset_repository.dart
    services/
      writing_scoring_service.dart
      quiz_generation_service.dart
      xp_service.dart
      level_service.dart
      badge_service.dart

  data/
    supabase/
      supabase_client_provider.dart
      supabase_tables.dart
    local/
      app_database.dart
      dao/
    repositories/
      auth_repository_impl.dart
      school_repository_impl.dart
      content_repository_impl.dart
      learning_repository_impl.dart
      progress_repository_impl.dart
      asset_repository_impl.dart

  features/
    splash/
      splash_screen.dart
    auth/
      login_screen.dart
      login_controller.dart
      login_state.dart
    home/
      home_screen.dart
      home_controller.dart
      home_state.dart
    hanja_card/
      hanja_card_screen.dart
      hanja_card_controller.dart
      hanja_card_state.dart
      widgets/
    writing/
      writing_screen.dart
      writing_controller.dart
      writing_state.dart
      stroke_canvas.dart
      stroke_engine.dart
      stroke_models.dart
      stroke_scoring.dart
    quiz/
      quiz_screen.dart
      quiz_controller.dart
      quiz_state.dart
    game/
      typing_game_screen.dart
      typing_game_controller.dart
      typing_game_state.dart
    result/
      result_screen.dart
      result_controller.dart
      result_state.dart
    growth/
      growth_screen.dart
      growth_controller.dart
      growth_state.dart
    teacher_preview/
      teacher_preview_screen.dart
      teacher_preview_controller.dart
```

## Routing

Use `go_router`.

```txt
/                         Splash
/login                    School search + student entry
/home                     Student home
/hanja/:hanjaId           Hanja card
/writing/:hanjaId         Writing practice
/quiz                     Quiz
/game                     Typing selection game
/result                   Result
/growth                   Growth
/teacher-preview          Teacher preview
```

## State Management

Use Riverpod.

- Use `AsyncNotifier` for async loading features.
- Use immutable state classes.
- Each feature has a controller.
- UI subscribes to controller state and sends user events.

## Repository Interfaces

Define interfaces in `domain/repositories`.
Implement them in `data/repositories`.

Required interfaces:

- `AuthRepository`
- `SchoolRepository`
- `ContentRepository`
- `LearningRepository`
- `ProgressRepository`
- `AssetRepository`

## Data Sources

MVP should use Supabase for:

- schools
- profiles
- learning_sessions
- writing_attempts
- user_hanja_progress
- xp_events

MVP may use local seed assets for:

- initial hanja data
- initial quiz data
- demo images
- fallback stroke data

The code must allow replacing local content source with Supabase content repository later.

## Testing Rules

Minimum tests:

- model JSON parsing
- school CSV normalization script
- quiz option generation
- writing score calculation
- XP/level calculation
