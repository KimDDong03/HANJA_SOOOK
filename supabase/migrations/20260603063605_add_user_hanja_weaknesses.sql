create table if not exists public.user_hanja_weaknesses (
  user_id uuid not null references auth.users(id) on delete cascade,
  hanja_id text not null references public.hanja_characters(id) on delete cascade,
  weakness_type text not null check (
    weakness_type in (
      'hun_meaning',
      'hanja_recognition',
      'writing',
      'shape_confusion',
      'retention'
    )
  ),
  score int not null default 0 check (score between 0 and 10),
  status text not null default 'watching' check (
    status in ('watching', 'active', 'resolved')
  ),
  mistake_count int not null default 0,
  success_streak int not null default 0,
  last_event_at timestamptz not null default now(),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, hanja_id, weakness_type)
);

create index if not exists idx_user_hanja_weaknesses_active
on public.user_hanja_weaknesses(user_id, status, score desc, last_event_at desc);

create trigger trg_user_hanja_weaknesses_updated_at
before update on public.user_hanja_weaknesses
for each row execute function public.set_updated_at();

alter table public.user_hanja_weaknesses enable row level security;

create policy "weakness owner select" on public.user_hanja_weaknesses
for select to authenticated
using (auth.uid() = user_id);

create policy "weakness owner insert" on public.user_hanja_weaknesses
for insert to authenticated
with check (auth.uid() = user_id);

create policy "weakness owner update" on public.user_hanja_weaknesses
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
