-- Align speed quiz config with the app policy: one 60-second limit per game.
insert into public.app_configs (key, value, description)
values ('game_time_limit_sec', '60', 'Total seconds per speed quiz game')
on conflict (key) do update
set value = excluded.value,
    description = excluded.description,
    updated_at = now();
