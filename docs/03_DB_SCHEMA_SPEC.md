# 03. Supabase DB Schema Specification

This specification is implemented by `supabase/migrations/0001_initial_schema.sql`.

## MVP Tables

### schools

Source: `data/source/학교기본정보_2026년03월31일기준.csv`

| Column | Source Column | Description |
|---|---|---|
| standard_school_code | 행정표준코드 | 내부 표준학교코드 |
| office_code | 시도교육청코드 | 시도교육청코드 |
| office_name | 시도교육청명 | 시도교육청명 |
| school_name | 학교명 | 검색/표시용 학교명 |
| school_name_eng | 영문학교명 | 영문명 |
| school_kind | 학교종류명 | MVP는 초등학교만 사용 |
| region_name | 시도명 | 지역 표시 |
| jurisdiction_name | 관할조직명 | 관할 교육지원청 |
| establishment_type | 설립명 | 공립/사립 등 |
| road_zip_code | 도로명우편번호 | 우편번호 |
| road_address | 도로명주소 | 주소 |
| road_detail_address | 도로명상세주소 | 상세주소 |
| phone_number | 전화번호 | 전화번호 |
| homepage_url | 홈페이지주소 | 홈페이지 |
| coeducation_type | 남녀공학구분명 | 남녀공학 |
| fax_number | 팩스번호 | 팩스 |
| founded_at | 설립일자 | 원본 문자열 |
| anniversary_at | 개교기념일 | 원본 문자열 |
| source_updated_at | 수정일자 | 원본 수정일 |

### profiles

Supabase Auth user와 1:1 연결된다.

- id: `auth.users.id`
- role: student/teacher/admin
- display_name
- school_id
- standard_school_code
- school_name
- grade
- class_name
- level
- total_xp
- coins
- is_demo

### Content Tables

- `hanja_characters`
- `hanja_examples`
- `quiz_questions`
- `stroke_assets`
- `content_assets`

### Learning Tables

- `learning_sessions`
- `writing_attempts`
- `user_hanja_progress`
- `xp_events`
- `user_badges`

### Config Tables

- `app_configs`
- `xp_rules`
- `level_rules`
- `badges`
- `content_versions`

## RLS Policy Summary

### Public/anon readable

- `schools`: active rows only, for login school search.

### Authenticated readable

- active `hanja_characters`
- active `hanja_examples`
- active `quiz_questions`
- active `stroke_assets`
- active `content_assets`
- active config/rule/badge tables

### Owner-only data

- `profiles`: own profile
- `learning_sessions`: own sessions
- `writing_attempts`: own attempts
- `user_hanja_progress`: own progress
- `xp_events`: own XP events
- `user_badges`: own badges

Admin/service role bypasses RLS through Supabase service role.

## MVP Login Data Flow

```txt
LoginScreen searches schools as anon
→ user selects school
→ Supabase anonymous sign-in
→ profiles upsert with selected school
→ app operates as authenticated user
```

## Import Strategy

1. Run `tools/school_seed/import_school_csv.py`.
2. It reads cp949 CSV.
3. It filters `학교종류명 == '초등학교'`.
4. It writes `supabase/seed/schools_elementary_seed.csv`.
5. Import CSV into `schools` table through Supabase Studio or SQL copy workflow.
