alter table public.profiles
add column if not exists avatar_key text not null default 'explorer';
