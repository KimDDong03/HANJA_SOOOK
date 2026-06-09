-- Hanjasoook MVP initial schema
-- Supabase/Postgres

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Schools
create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  standard_school_code text not null unique,
  office_code text,
  office_name text,
  school_name text not null,
  school_name_eng text,
  school_kind text,
  region_name text,
  jurisdiction_name text,
  establishment_type text,
  road_zip_code text,
  road_address text,
  road_detail_address text,
  phone_number text,
  homepage_url text,
  coeducation_type text,
  fax_number text,
  founded_at text,
  anniversary_at text,
  source_updated_at text,
  is_active boolean not null default true,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_schools_school_name_trgm on public.schools using gin (school_name gin_trgm_ops);
create index if not exists idx_schools_kind_active on public.schools (school_kind, is_active);
create index if not exists idx_schools_region on public.schools (region_name);

create trigger trg_schools_updated_at
before update on public.schools
for each row execute function public.set_updated_at();

-- Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'student' check (role in ('student', 'teacher', 'admin')),
  display_name text not null,
  school_id uuid references public.schools(id),
  standard_school_code text,
  school_name text,
  grade int check (grade between 1 and 6),
  class_name text,
  level int not null default 1,
  total_xp int not null default 0,
  coins int not null default 0,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_school on public.profiles (school_id);
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Content version
create table if not exists public.content_versions (
  id uuid primary key default gen_random_uuid(),
  version_name text not null unique,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  published_at timestamptz,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_content_versions_updated_at
before update on public.content_versions
for each row execute function public.set_updated_at();

-- Assets
create table if not exists public.content_assets (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('hanja_image', 'character', 'badge', 'background', 'icon', 'stroke')),
  title text not null,
  storage_path text,
  public_url text,
  related_hanja_id text,
  grade int,
  level int,
  license_note text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_content_assets_type_active on public.content_assets(type, is_active);
create trigger trg_content_assets_updated_at
before update on public.content_assets
for each row execute function public.set_updated_at();

-- Hanja characters
create table if not exists public.hanja_characters (
  id text primary key,
  character text not null,
  sound text not null,
  meaning text not null,
  stroke_count int,
  grade int not null check (grade between 1 and 6),
  unit_code text,
  unit_name text,
  lesson_no int,
  difficulty text not null default 'normal' check (difficulty in ('easy', 'normal', 'hard')),
  example_sentence text,
  example_meaning text,
  image_asset_id uuid references public.content_assets(id),
  stroke_asset_id uuid,
  sort_order int not null default 0,
  content_version_id uuid references public.content_versions(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_hanja_grade_unit on public.hanja_characters(grade, unit_code, sort_order);
create index if not exists idx_hanja_active on public.hanja_characters(is_active);
create trigger trg_hanja_characters_updated_at
before update on public.hanja_characters
for each row execute function public.set_updated_at();

-- Examples
create table if not exists public.hanja_examples (
  id uuid primary key default gen_random_uuid(),
  hanja_id text not null references public.hanja_characters(id) on delete cascade,
  sentence text not null,
  meaning text,
  source text,
  difficulty text not null default 'normal' check (difficulty in ('easy', 'normal', 'hard')),
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_hanja_examples_hanja on public.hanja_examples(hanja_id, sort_order);
create trigger trg_hanja_examples_updated_at
before update on public.hanja_examples
for each row execute function public.set_updated_at();

-- Quiz
create table if not exists public.quiz_questions (
  id text primary key,
  hanja_id text references public.hanja_characters(id) on delete set null,
  grade int not null check (grade between 1 and 6),
  unit_code text,
  type text not null check (type in ('sound_choice', 'meaning_choice', 'hanja_choice', 'sentence_blank')),
  prompt text not null,
  correct_answer text not null,
  options jsonb not null default '[]'::jsonb,
  explanation text,
  difficulty text not null default 'normal' check (difficulty in ('easy', 'normal', 'hard')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_quiz_grade_unit on public.quiz_questions(grade, unit_code);
create index if not exists idx_quiz_active on public.quiz_questions(is_active);
create trigger trg_quiz_questions_updated_at
before update on public.quiz_questions
for each row execute function public.set_updated_at();

-- Stroke assets
create table if not exists public.stroke_assets (
  id uuid primary key default gen_random_uuid(),
  hanja_id text references public.hanja_characters(id) on delete cascade,
  character text not null,
  source text not null default 'fallback',
  data_format text not null default 'manual' check (data_format in ('median_json', 'svg', 'path_json', 'manual')),
  storage_path text,
  stroke_count int,
  median_points jsonb,
  svg_paths jsonb,
  license_note text,
  review_status text not null default 'missing' check (review_status in ('available', 'needs_review', 'missing', 'manual_required')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.hanja_characters
  add constraint fk_hanja_stroke_asset foreign key (stroke_asset_id) references public.stroke_assets(id);

create index if not exists idx_stroke_assets_hanja on public.stroke_assets(hanja_id);
create index if not exists idx_stroke_assets_status on public.stroke_assets(review_status);
create trigger trg_stroke_assets_updated_at
before update on public.stroke_assets
for each row execute function public.set_updated_at();

-- App configs
create table if not exists public.app_configs (
  key text primary key,
  value jsonb not null,
  description text,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- XP rules
create table if not exists public.xp_rules (
  source text primary key,
  amount int not null,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

-- Level rules
create table if not exists public.level_rules (
  level int primary key,
  required_xp int not null
);

-- Badges
create table if not exists public.badges (
  code text primary key,
  title text not null,
  description text,
  condition_type text,
  condition_value int,
  asset_id uuid references public.content_assets(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_badges_updated_at
before update on public.badges
for each row execute function public.set_updated_at();

-- Learning sessions
create table if not exists public.learning_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mode text not null check (mode in ('card', 'writing', 'quiz', 'game')),
  grade int,
  unit_code text,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  score int not null default 0,
  accuracy numeric not null default 0,
  time_sec int not null default 0,
  earned_xp int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists idx_learning_sessions_user on public.learning_sessions(user_id, created_at desc);

-- Writing attempts
create table if not exists public.writing_attempts (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.learning_sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  hanja_id text references public.hanja_characters(id) on delete set null,
  accuracy numeric not null default 0,
  stars int not null default 0 check (stars between 0 and 3),
  expected_stroke_count int,
  user_stroke_count int,
  time_sec int not null default 0,
  scoring_mode text not null default 'fallback' check (scoring_mode in ('guided', 'free', 'fallback')),
  raw_path_saved boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_writing_attempts_user on public.writing_attempts(user_id, created_at desc);

-- User Hanja progress
create table if not exists public.user_hanja_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  hanja_id text not null references public.hanja_characters(id) on delete cascade,
  status text not null default 'not_started' check (status in ('not_started', 'learning', 'completed', 'review')),
  card_viewed_count int not null default 0,
  writing_completed_count int not null default 0,
  quiz_correct_count int not null default 0,
  best_writing_accuracy numeric not null default 0,
  best_quiz_score int not null default 0,
  last_studied_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, hanja_id)
);

create trigger trg_user_hanja_progress_updated_at
before update on public.user_hanja_progress
for each row execute function public.set_updated_at();

-- XP events
create table if not exists public.xp_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source text not null,
  amount int not null,
  ref_table text,
  ref_id text,
  created_at timestamptz not null default now()
);

create index if not exists idx_xp_events_user on public.xp_events(user_id, created_at desc);

-- User badges
create table if not exists public.user_badges (
  user_id uuid not null references auth.users(id) on delete cascade,
  badge_code text not null references public.badges(code) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, badge_code)
);

-- RLS
alter table public.schools enable row level security;
alter table public.profiles enable row level security;
alter table public.content_versions enable row level security;
alter table public.content_assets enable row level security;
alter table public.hanja_characters enable row level security;
alter table public.hanja_examples enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.stroke_assets enable row level security;
alter table public.app_configs enable row level security;
alter table public.xp_rules enable row level security;
alter table public.level_rules enable row level security;
alter table public.badges enable row level security;
alter table public.learning_sessions enable row level security;
alter table public.writing_attempts enable row level security;
alter table public.user_hanja_progress enable row level security;
alter table public.xp_events enable row level security;
alter table public.user_badges enable row level security;

-- Read active schools before auth for school search
create policy "schools active readable" on public.schools
for select to anon, authenticated
using (is_active = true);

-- Profiles owner policies
create policy "profiles owner select" on public.profiles
for select to authenticated
using (auth.uid() = id);

create policy "profiles owner insert" on public.profiles
for insert to authenticated
with check (auth.uid() = id);

create policy "profiles owner update" on public.profiles
for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- Active content read policies
create policy "content_versions published read" on public.content_versions
for select to authenticated
using (status = 'published');

create policy "content_assets active read" on public.content_assets
for select to authenticated
using (is_active = true);

create policy "hanja active read" on public.hanja_characters
for select to authenticated
using (is_active = true);

create policy "examples active read" on public.hanja_examples
for select to authenticated
using (is_active = true);

create policy "quiz active read" on public.quiz_questions
for select to authenticated
using (is_active = true);

create policy "stroke active read" on public.stroke_assets
for select to authenticated
using (is_active = true);

create policy "app_configs active read" on public.app_configs
for select to authenticated
using (is_active = true);

create policy "xp_rules active read" on public.xp_rules
for select to authenticated
using (is_active = true);

create policy "level_rules read" on public.level_rules
for select to authenticated
using (true);

create policy "badges active read" on public.badges
for select to authenticated
using (is_active = true);

-- Owner learning data policies
create policy "learning sessions owner select" on public.learning_sessions
for select to authenticated
using (auth.uid() = user_id);

create policy "learning sessions owner insert" on public.learning_sessions
for insert to authenticated
with check (auth.uid() = user_id);

create policy "learning sessions owner update" on public.learning_sessions
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "writing attempts owner select" on public.writing_attempts
for select to authenticated
using (auth.uid() = user_id);

create policy "writing attempts owner insert" on public.writing_attempts
for insert to authenticated
with check (auth.uid() = user_id);

create policy "progress owner select" on public.user_hanja_progress
for select to authenticated
using (auth.uid() = user_id);

create policy "progress owner insert" on public.user_hanja_progress
for insert to authenticated
with check (auth.uid() = user_id);

create policy "progress owner update" on public.user_hanja_progress
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "xp owner select" on public.xp_events
for select to authenticated
using (auth.uid() = user_id);

create policy "xp owner insert" on public.xp_events
for insert to authenticated
with check (auth.uid() = user_id);

create policy "user badges owner select" on public.user_badges
for select to authenticated
using (auth.uid() = user_id);

create policy "user badges owner insert" on public.user_badges
for insert to authenticated
with check (auth.uid() = user_id);

-- Default config seed
insert into public.app_configs (key, value, description) values
  ('daily_hanja_count', '5', 'Number of daily Hanja cards'),
  ('quiz_question_count', '10', 'Number of quiz questions'),
  ('game_question_count', '10', 'Number of game questions'),
  ('game_time_limit_sec', '60', 'Total seconds per speed quiz game'),
  ('writing_pass_score', '65', 'Writing pass score'),
  ('writing_star_3_score', '85', '3-star threshold'),
  ('writing_star_2_score', '65', '2-star threshold'),
  ('writing_star_1_score', '45', '1-star threshold')
on conflict (key) do nothing;

insert into public.xp_rules (source, amount) values
  ('card_complete', 10),
  ('writing_complete', 15),
  ('quiz_correct', 5),
  ('quiz_complete', 20),
  ('game_correct', 5),
  ('game_complete', 20),
  ('daily_mission_complete', 30)
on conflict (source) do nothing;

insert into public.level_rules (level, required_xp) values
  (1, 0),
  (2, 100),
  (3, 250),
  (4, 450),
  (5, 700),
  (6, 1000),
  (7, 1350),
  (8, 1750),
  (9, 2200),
  (10, 2700),
  (11, 3250),
  (12, 3850),
  (13, 4500),
  (14, 5200),
  (15, 5950),
  (16, 6750),
  (17, 7600),
  (18, 8500),
  (19, 9450),
  (20, 10450)
on conflict (level) do nothing;

insert into public.badges (code, title, description, condition_type, condition_value) values
  ('first_learning', '첫 학습 완료', '첫 한자 학습을 완료했어요.', 'completed_hanja_count', 1),
  ('perfect_quiz', '퀴즈 첫 만점', '퀴즈에서 처음으로 만점을 받았어요.', 'perfect_quiz_count', 1),
  ('writing_three_star', '따라쓰기 별 3개', '따라쓰기에서 별 3개를 받았어요.', 'writing_three_star_count', 1),
  ('seven_days', '7일 출석', '7일 연속 학습했어요.', 'streak_days', 7),
  ('fifty_hanja', '50자 달성', '한자 50개를 완료했어요.', 'completed_hanja_count', 50)
on conflict (code) do nothing;
