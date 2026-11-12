-- WINter Fantasy: organizer-controlled squad lock.
-- Run once in Supabase → SQL Editor (after 005_captain.sql).
--   auto   = squads are open until the first kick-off, then locked (default)
--   locked = an organizer locked squads for everyone
--   open   = an organizer unlocked squads for everyone (works after kick-off too)
-- While locked, nobody can add, remove, swap players or change their captain.

create table if not exists public.league_settings (
  id         int primary key default 1 check (id = 1),
  lock_mode  text not null default 'auto' check (lock_mode in ('auto', 'locked', 'open')),
  updated_at timestamptz not null default now(),
  updated_by uuid
);
insert into public.league_settings (id) values (1) on conflict (id) do nothing;

alter table public.league_settings enable row level security;
drop policy if exists "read settings" on public.league_settings;
create policy "read settings" on public.league_settings for select to authenticated using (true);
grant select on public.league_settings to authenticated;

do $$
begin
  begin alter publication supabase_realtime add table public.league_settings; exception when others then null; end;
end $$;

-- Squads can be saved only while this is true (used by the squads policies).
create or replace function public.squads_open() returns boolean
language sql stable security definer set search_path = public as $$
  select case (select lock_mode from public.league_settings where id = 1)
    when 'locked' then false
    when 'open'   then true
    else now() < timestamptz '2026-11-12 12:30:00-06'
  end;
$$;
grant execute on function public.squads_open() to authenticated;

-- Organizers only. Unlocking also clears any squad that was locked on its own.
create or replace function public.set_lock_mode(mode text) returns text
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    raise exception 'Only organizers can lock or unlock squads.';
  end if;
  if mode not in ('auto', 'locked', 'open') then
    raise exception 'Unknown lock mode: %', mode;
  end if;
  update public.league_settings set lock_mode = mode, updated_at = now(), updated_by = auth.uid() where id = 1;
  if mode = 'open' then
    update public.squads set locked = false where locked;
  end if;
  return mode;
end;
$$;
revoke all on function public.set_lock_mode(text) from public, anon;
grant execute on function public.set_lock_mode(text) to authenticated;
