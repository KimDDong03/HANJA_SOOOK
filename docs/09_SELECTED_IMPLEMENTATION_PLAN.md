# 09. Selected Implementation Plan

## 목적

`docs/08_SELECTED_SCREEN_SPEC.md`를 실제 Flutter 구현 순서로 바꾸기 위한 작업 계획이다.
기존 `docs/06_CODEX_TASKS.md`는 초기 MVP 기준으로 유지하고, 이 문서는 새 선택안 기준의 후속 구현 계획으로 사용한다.

## 현재 코드 기준

이미 존재:

- `lib/app/router.dart`
- `lib/core/constants/route_paths.dart`
- `features/splash`
- `features/auth` 로그인/학교 검색
- `features/home`
- `features/hanja_card`
- `features/writing`
- `features/quiz`
- `features/game`
- `features/result`
- `features/growth`
- `features/student_links`
- `features/teacher_preview`

새 선택안 기준으로 필요한 것:

- Role Select
- Student Setup alias 또는 기존 Login 재구성
- App Shell with bottom tabs
- Learn tab hub
- Challenge tab hub
- Settings tab with role-specific content
- Writing Mode Select
- Free Writing Score route/state separation
- Quiz Modes
- Flip Board Game
- Class Ranking

## 라우트 제안

기존 라우트를 한 번에 삭제하지 않는다.
새 라우트를 추가하고, 기존 화면은 새 구조 아래로 연결한다.

```txt
/                         Splash
/role-select              Role Select
/student-setup            Student Setup

/app/home                 Home tab
/app/learn                Learn tab
/app/challenge            Challenge tab
/app/settings             Settings tab

/app/learn/hanja/:hanjaId Hanja Card
/app/learn/writing-modes/:hanjaId
/app/learn/guided-writing/:hanjaId
/app/learn/free-writing/:hanjaId

/app/challenge/quiz       Quiz Modes
/app/challenge/quiz/play  Quiz Play
/app/challenge/flip-board Flip Board Game
/app/challenge/ranking    Class Ranking

/result                   Result

/student-links            Existing Student Links, later nested under Settings
/teacher-preview          Existing Teacher Preview, later nested under Settings
```

호환 유지:

- 기존 `/login`은 당분간 `/student-setup`과 같은 화면으로 연결 가능
- 기존 `/home`은 `/app/home`으로 redirect 가능
- 기존 `/hanja/:hanjaId`는 `/app/learn/hanja/:hanjaId`로 redirect 가능
- 기존 `/writing/:hanjaId`는 `/app/learn/guided-writing/:hanjaId`로 redirect 가능
- 기존 `/quiz`는 `/app/challenge/quiz`로 redirect 가능
- 기존 `/game`은 `/app/challenge` 또는 기존 Typing Game으로 유지 가능

## 구현 순서

### Ticket S00. Route Constants 확장

목표:

- 새 선택안 라우트 상수를 추가한다.
- 기존 라우트는 호환용으로 남긴다.

변경:

- `lib/core/constants/route_paths.dart`

Acceptance:

- 새 라우트 helper가 존재한다.
- 기존 route helper가 깨지지 않는다.
- `flutter analyze` 통과.

### Ticket S01. Role Select

목표:

- 학생/학부모/선생님 role 선택 화면을 만든다.

파일:

- `lib/features/role_select/role_select_screen.dart`
- 필요 시 `role_select_controller.dart`

동작:

- 학생 선택: `/student-setup`
- 학부모 선택: `/app/settings?role=parent` 또는 설정 role 상태 변경
- 선생님 선택: `/app/settings?role=teacher` 또는 `/teacher-preview`

Acceptance:

- Splash 이후 Role Select로 이동할 수 있다.
- 학생 CTA가 가장 강하게 보인다.
- 학부모/선생님 기능이 학생 홈에 노출되지 않는다.

### Ticket S02. Student Setup

목표:

- 기존 `LoginScreen`의 학교 검색/이름/학년 입력을 Student Setup 개념으로 정리한다.

파일:

- 기존 `lib/features/auth/login_screen.dart` 재사용 또는
- `lib/features/student_setup/student_setup_screen.dart`

동작:

- 학교 검색 정책은 기존 Product Spec 유지
- 1/2학년은 준비중 또는 비활성
- 3~6학년 활성
- 시작하기 후 `/app/home`

Acceptance:

- 기존 학교 검색/학생 생성 흐름이 깨지지 않는다.
- validation 문구는 `docs/02_PRODUCT_SPEC.md`와 일치한다.
- `/login` 호환 경로가 동작한다.

### Ticket S03. App Shell + Bottom Tabs

목표:

- `홈 / 학습 / 도전 / 설정` 하단 탭 구조를 만든다.

파일:

- `lib/app/app_shell.dart` 또는 `lib/features/shell/app_shell.dart`
- `lib/app/router.dart`

구성:

- ShellRoute 또는 탭 Scaffold
- 탭별 active state
- 홈, 학습, 도전, 설정 라우트 연결

Acceptance:

- `/app/home`, `/app/learn`, `/app/challenge`, `/app/settings`가 하단 탭과 함께 표시된다.
- 상세 화면에서 탭을 유지할지 숨길지 일관된 규칙이 있다.
- 기존 HomeScreen은 `/app/home`에서 접근 가능하다.

### Ticket S04. Home 재정리

목표:

- 홈을 단원 학습 중심으로 정리한다.

기존 활용:

- `lib/features/home/home_screen.dart`
- `lib/features/home/home_controller.dart`

변경 방향:

- Teacher Preview, Student Links 직접 카드 제거 또는 설정으로 이동
- 단원 카드, 진행률, 시작 CTA 우선
- XP/성장 요약 추가
- 도전/랭킹 요약은 보조로만 표시

Acceptance:

- 홈 첫 CTA는 `단원 학습 시작`.
- 학부모/선생님 기능은 홈 주요 카드로 보이지 않는다.
- Empty/loading/error 상태 유지.

### Ticket S05. Learn Tab Hub

목표:

- 학습 탭 첫 화면을 만든다.

파일:

- `lib/features/learn/learn_screen.dart`
- `lib/features/learn/learn_controller.dart`

구성:

- 단원별 한자장
- 복습/집중 대상
- 단원 학습 CTA
- 현재/완료/잠김/fallback 상태

Acceptance:

- `/app/learn`에서 학습 루트가 보인다.
- 한자 카드와 쓰기 모드 선택으로 이동 가능.
- 단원 한자 데이터가 없으면 fallback 표시.

### Ticket S06. Hanja Card Route 재배치

목표:

- 기존 Hanja Card를 새 학습 라우트 아래로 연결한다.

파일:

- `lib/features/hanja_card/hanja_card_screen.dart`
- `lib/app/router.dart`

변경 방향:

- `/app/learn/hanja/:hanjaId` 추가
- CTA를 `획순 보기`, `쓰기 연습`, `도전 문제` 위계로 조정
- 기존 `/hanja/:hanjaId`는 새 라우트로 호환

Acceptance:

- 새 Learn 화면에서 Hanja Card 접근 가능.
- 누락 이미지/예문/획순 fallback 유지.

### Ticket S07. Writing Mode Select

목표:

- 기본 흐름 밖에서 연습과 채점을 바로 고를 수 있는 보조 선택 화면을 만든다.

파일:

- `lib/features/writing/writing_mode_select_screen.dart`
- 필요 시 `writing_mode_controller.dart`

모드:

- 직접 써보기
- 자유쓰기 채점

Acceptance:

- Hanja Card 기본 CTA는 직접 써보기로 이동한다.
- 보조 선택 화면에서는 직접 써보기와 free writing route로 연결된다.
- 획순 데이터 없음 fallback이 명확하다.

### Ticket S08. Direct Writing 개선

목표:

- 기존 WritingScreen을 직접 써보기 단일 흐름으로 정리한다.

기존 활용:

- `lib/features/writing/writing_screen.dart`
- `writing_controller.dart`
- `widgets/hanja_writing_practice_canvas.dart`
- `widgets/hanja_free_writing_canvas.dart`

변경 방향:

- 회색 전체 글자 가이드 위에 직접 쓰기
- 첫 연습은 획순 애니메이션을 먼저 보여주고, 이후에는 `획순 보기` 버튼으로 재생
- 예문 또는 낱말 예시를 함께 보여준다.
- 3회 따라쓰기 후 Free Writing Score로 이동한다.
- 각 연습을 성공하면 `잘했어요!` 피드백을 짧게 보여주고 자동으로 다음 단계로 이동한다.
- 오답 시 위치만 한 번 강조
- 완료 후 Free Writing Score 이동

Acceptance:

- 기존 쓰기 기능이 깨지지 않는다.
- missing stroke asset이면 free writing으로 fallback.
- scoring 로직은 UI에 두지 않는다.

### Ticket S09. Free Writing Score

목표:

- 아무 안내 없이 쓰고 채점받는 화면을 분리한다.
- 채점 후 숫자 점수/별을 중간 화면에 노출하지 않고 바로 Result로 이동한다.
- Result에는 통과/다시 연습 판정만 노출한다.

파일:

- `lib/features/writing/free_writing_score_screen.dart`
- 필요 시 기존 free writing canvas 재사용

구성:

- 큰 빈 캔버스
- 다시쓰기
- 채점받기
- 채점 후 점수/별/재도전/결과 이동

Acceptance:

- 가이드/획순/정답선을 보여주지 않는다.
- 채점 결과를 Result로 전달할 수 있다.
- Hanja demo식 무안내 채점 경로로 재사용 가능.

### Ticket S10. Challenge Tab Hub

목표:

- 도전 탭 첫 화면을 만든다.

파일:

- `lib/features/challenge/challenge_screen.dart`
- `challenge_controller.dart`

구성:

- 반 경쟁 요약
- 오늘 도전 점수
- 퀴즈
- 판뒤집기
- 반 랭킹

Acceptance:

- `/app/challenge`에서 quiz/game/ranking 진입 가능.
- 반 데이터가 없으면 demo/sample fallback 표시.

### Ticket S11. Quiz Modes + Quiz Play 재정리

목표:

- 기존 Quiz를 모드 선택 + 공통 플레이 구조로 재정리한다.

기존 활용:

- `lib/features/quiz/quiz_screen.dart`
- `quiz_controller.dart`

새 파일 가능:

- `quiz_modes_screen.dart`
- `quiz_play_screen.dart`

모드:

- 한자 보고 훈음
- 훈음 보고 한자
- 혼합 퀴즈

분리:

- 뜻 보고 한자 선택 속도형은 별도 도전/게임으로 둔다.

Acceptance:

- 세 모드가 공통 퀴즈 프레임을 공유한다.
- 문제 유형별 prompt/answer area가 바뀐다.
- 마지막 문제 후 Result 이동.

### Ticket S12. Typing Selection Game 위치 정리

목표:

- 기존 `TypingGameScreen`을 도전 탭의 속도형 게임으로 재배치한다.

기존 활용:

- `lib/features/game/typing_game_screen.dart`
- `typing_game_controller.dart`

Acceptance:

- `/app/challenge`에서 접근 가능.
- `뜻 보고 한자 선택`은 Quiz Play가 아니라 speed/combo game으로 표시된다.

### Ticket S13. Flip Board Game

목표:

- 판뒤집기 MVP 화면과 상태 모델을 만든다.

파일:

- `lib/features/flip_board/flip_board_screen.dart`
- `flip_board_controller.dart`
- 필요 시 `domain/models/flip_board_game.dart`

규칙:

- 학생이 판을 직접 선택한다.
- 진입 전에 `훈음 보고 한자 그리기` 또는 `한자 보고 뜻 쓰기` 모드를 선택한다.
- `훈음 보고 한자 그리기` 모드는 판에 훈음만 보여주고 한자를 그려서 답한다.
- `한자 보고 뜻 쓰기` 모드는 판에 한자만 보여주고 훈음 또는 뜻을 타이핑해서 답한다.
- 정답이면 선택한 판이 내 색으로 바뀐다.
- 기본형/리버스형/반 경쟁형/라운드 전략형을 모드/상태로 지원한다.

MVP:

- 실시간 대전 없음.
- 로컬/demo 데이터 기반.
- 결과는 ranking 기록 형태로 저장할 수 있게 인터페이스를 둔다.

Acceptance:

- 판 그리드가 보인다.
- 판 선택 후 답변 영역이 열린다.
- 정답/오답 피드백과 점유 상태가 바뀐다.
- Result 또는 Class Ranking으로 이동 가능.

### Ticket S14. Class Ranking

목표:

- 비동기 반 랭킹 화면을 만든다.

파일:

- `lib/features/class_ranking/class_ranking_screen.dart`
- `class_ranking_controller.dart`

필터:

- XP
- 오늘
- 판뒤집기

Acceptance:

- 반 데이터가 없으면 sample ranking 표시.
- 개인정보는 닉네임/가림 이름으로 표시.
- 도전 탭과 Result에서 접근 가능.

### Ticket S15. Result 확장

목표:

- 학습/퀴즈/게임 결과를 성장 보상형으로 통합한다.

기존 활용:

- `lib/features/result/result_screen.dart`
- `result_controller.dart`

변경 방향:

- activity type별 지표 표시
- XP bar
- 다음 행동 CTA
- 랭킹 보기 CTA

Acceptance:

- 쓰기/퀴즈/판뒤집기 결과를 모두 표현 가능.
- 기존 result query 호환이 깨지지 않는다.

### Ticket S16. Settings Role별 구조

목표:

- 설정 탭을 role별 화면으로 만든다.

파일:

- `lib/features/settings/settings_screen.dart`
- `settings_controller.dart`

role별 구성:

- 학생: 프로필, 학교/학년, 반 참여, 학습 설정, 역할 변경
- 학부모: 학생 연결, 연결된 학생, 학습 현황, 알림, 역할 변경
- 선생님: Teacher Preview, 샘플 반/학생 현황, 반 코드, 역할 변경

Acceptance:

- 선택된 role에 따라 설정 항목이 다르다.
- Student Links와 Teacher Preview는 Settings에서 접근 가능.
- Home에 학부모/교사 기능이 섞이지 않는다.

### Ticket S17. Growth 재배치

목표:

- 기존 Growth 화면을 별도 탭이 아니라 홈 요약/결과/상세 화면으로 재배치한다.

기존 활용:

- `lib/features/growth/growth_screen.dart`
- `growth_controller.dart`

Acceptance:

- 기존 `/growth`는 호환용으로 유지하거나 상세 화면으로 남긴다.
- 하단 탭에서는 Growth가 사라진다.
- XP/레벨/배지 정보는 Home/Result에 요약된다.

### Ticket S18. QA and Demo Flow

목표:

- 새 선택안 기준으로 주요 흐름을 검증한다.

검증 흐름:

```txt
Splash
→ Role Select
→ Student Setup
→ Home
→ Learn
→ Hanja Card
→ Writing Mode Select
→ Guided Writing
→ Free Writing Score
→ Result
→ Challenge
→ Quiz Modes
→ Quiz Play
→ Result
→ Flip Board Game
→ Class Ranking
→ Settings
```

Acceptance:

- `flutter analyze` 통과.
- 주요 route 접근 가능.
- loading/empty/error 상태 표시.
- demo fallback으로 흐름이 막히지 않음.

## 구현 리스크

| 리스크 | 대응 |
|---|---|
| 기존 라우트와 새 라우트가 중복됨 | 새 라우트 추가 후 기존 라우트는 redirect/호환으로 유지 |
| 하단 탭과 상세 화면의 nav 규칙 혼선 | App Shell 티켓에서 탭 유지/숨김 규칙 먼저 고정 |
| 판뒤집기 범위가 큼 | 1차는 demo/local 상태 기반으로 구현 |
| 반 랭킹에 개인정보 이슈 | 닉네임/가림 이름 사용 |
| Growth 제거로 보상 동기 약화 | Home/Result에서 XP/레벨 요약 강화 |

## 우선 구현 추천

가장 먼저 할 구현 묶음:

1. RoutePaths 확장
2. Role Select
3. Student Setup alias
4. App Shell + 4 tabs
5. Home에서 보조 기능 제거/설정 이동
6. Learn/Challenge/Settings placeholder

이 묶음이 끝나면 새 IA가 앱에서 실제로 보이고, 이후 기능 화면을 하나씩 채우면 된다.
