# AGENTS.md

## Role
You are an implementation agent for the Hanjasoook Flutter project.
You must not make product decisions. Implement exactly from the specs in this repository.

When the user says **"구현 시작해"**, start from `docs/06_CODEX_TASKS.md` Ticket 00 only. If this repository has no `pubspec.yaml`, initialize Flutter in the root with `flutter create . --platforms=android,ios` while preserving existing docs/supabase/tools files.
Do not jump ahead to later tickets unless the user explicitly asks.

## Project
한자쏘옥 is an elementary Hanja learning app.
The first milestone is a demo-ready MVP, but the code must be maintainable enough to extend into a real service.

## Tech Stack
Use only the following default stack unless explicitly instructed otherwise.

- Flutter
- Supabase, not Firebase
- flutter_riverpod for state management
- go_router for routing
- freezed + json_serializable for immutable models and JSON parsing
- drift for local cache and pending sync
- flutter_svg for SVG rendering
- stroke_order_animator may be used only behind a StrokeEngine adapter

## Architecture Rule
All code must follow this dependency direction:

```txt
Screen / Widget
→ Controller / Notifier
→ Domain Service
→ Repository Interface
→ Repository Implementation
→ Supabase / Drift / Asset / Storage Data Source
```

Forbidden:

- UI must not call Supabase directly.
- UI must not parse raw Supabase maps directly.
- UI must not compute XP, levels, quiz scoring, or handwriting accuracy directly.
- Data layer must not import feature UI code.
- Domain layer must not depend on Flutter widgets.
- `stroke_order_animator` must not be imported directly by `WritingScreen`.

## MVP Scope
Included in MVP:

- Splash
- School search and student entry
- Student home
- Hanja card
- Writing practice
- Quiz
- Typing/selection game
- Result
- Growth
- Teacher preview UI only

Excluded from MVP unless explicitly requested:

- Firebase
- Full web admin
- Full teacher assignment backend
- Parent app
- Payment
- Social sharing
- AI handwriting scoring
- Speech recognition
- Real-time ranking
- Complex LMS
- Full App Store automation

## Package Policy
Do not add a new package unless all of the following are true:

1. It directly solves the current ticket.
2. It is not already covered by the approved stack.
3. You state why it is needed.
4. The user approves, unless the package is already listed in the approved stack.

## Code Style
- Prefer small files and small widgets.
- Keep widgets dumb; move logic to controller/service.
- Use immutable models.
- Use explicit error states.
- Add TODO comments only for planned extension points, not unfinished current-ticket requirements.
- Prefer clear names over clever abstractions.
- Korean UI text is allowed; code identifiers must be English.

## State Pattern
Use Riverpod Notifiers or AsyncNotifiers.
Each feature should have:

- screen file
- controller/notifier file
- state model when needed
- small widgets folder if UI becomes large

## Environment
Supabase URL and anon key must come from `--dart-define`.
Do not hard-code secrets.

Expected keys:

```txt
SUPABASE_URL
SUPABASE_ANON_KEY
APP_ENV
```

## School Data
Use `data/source/학교기본정보_2026년03월31일기준.csv` as the source file.
CSV encoding is `cp949`.
The standard school code is CSV column `행정표준코드`.
For MVP, use only rows where `학교종류명 == '초등학교'`.

## Writing Engine
The writing feature must be designed around `StrokeEngine`.
There must be a fallback free-writing mode when stroke data is missing or invalid.
The first MVP must never block demo flow because of missing stroke data.

## Quality Gate
A ticket is complete only when:

- Code compiles.
- `flutter analyze` passes.
- Added tests pass, where applicable.
- Empty/loading/error states are handled.
- The implemented route can be reached.
- No forbidden scope was added.

## If Unsure
Do not invent product behavior.
Use the defaults in `docs/02_PRODUCT_SPEC.md` and `docs/06_CODEX_TASKS.md`.
If a decision is not covered, stop and ask the user.
