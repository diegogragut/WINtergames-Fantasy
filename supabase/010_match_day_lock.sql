-- WINter Fantasy: squads lock around every match.
-- Run once in Supabase → SQL Editor (after 009_market_lock_save_fix.sql).
--   auto   = squads are open, except from 5 minutes before each kick-off until
--            45 minutes after it (12:25–13:15 for a 12:30 kick-off)
--   locked = an organizer locked squads for everyone (until they unlock)
--   open   = an organizer opened squads for everyone, even during a match
-- Kick-off times come from public.fixtures (007).

create or replace function public.squads_open() returns boolean
language sql stable security definer set search_path = public as $$
  select case (select lock_mode from public.league_settings where id = 1)
    when 'locked' then false
    when 'open'   then true
    else not exists (
      select 1 from public.fixtures f
      where now() >= f.kickoff - interval '5 minutes'
        and now() <  f.kickoff + interval '45 minutes')
  end;
$$;
grant execute on function public.squads_open() to authenticated;

-- Organizers only. Opening squads or going back to the schedule also clears any
-- squad that was locked on its own.
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
  if mode in ('open', 'auto') then
    update public.squads set locked = false where locked;
  end if;
  return mode;
end;
$$;
revoke all on function public.set_lock_mode(text) from public, anon;
grant execute on function public.set_lock_mode(text) to authenticated;

-- Switch to the match-day schedule now.
update public.league_settings set lock_mode = 'auto', updated_at = now() where id = 1;
update public.squads set locked = false where locked;
