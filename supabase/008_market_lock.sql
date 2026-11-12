-- WINter Fantasy: transfer market lock.
-- Run once in Supabase → SQL Editor (after 007_snapshots.sql).
-- When the market is closed, managers can't buy or sell players (the set of 7
-- players can't change), but they can still swap with the bench and change
-- captain while squads are open. The squad lock (006) still freezes everything.

alter table public.league_settings
  add column if not exists market_mode text not null default 'open'
  check (market_mode in ('open', 'locked'));

create or replace function public.market_open() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select market_mode from public.league_settings where id = 1), 'open') = 'open';
$$;
grant execute on function public.market_open() to authenticated;

create or replace function public.set_market_mode(mode text) returns text
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    raise exception 'Only organizers can open or close the transfer market.';
  end if;
  if mode not in ('open', 'locked') then
    raise exception 'Unknown market mode: %', mode;
  end if;
  update public.league_settings set market_mode = mode, updated_at = now(), updated_by = auth.uid() where id = 1;
  return mode;
end;
$$;
revoke all on function public.set_market_mode(text) from public, anon;
grant execute on function public.set_market_mode(text) to authenticated;

-- Same rules as 005, plus the market check. Changes run from the SQL editor
-- (no signed-in user) skip the market check so organizers can fix data.
create or replace function public.check_squad() returns trigger
language plpgsql as $$
declare
  bad text;
  total numeric;
  wanted text[] := array['GK','CB','CB','ST','ST'];
  i int;
  p text;
  ppos text;
begin
  if auth.uid() is not null and not public.market_open() then
    if tg_op = 'INSERT' then
      if exists (select 1 from unnest(new.slots) x where x is not null) then
        raise exception 'The transfer market is closed, so players can''t be bought right now.';
      end if;
    elsif (select coalesce(array_agg(x order by x), '{}') from unnest(new.slots) x where x is not null)
       <> (select coalesce(array_agg(x order by x), '{}') from unnest(old.slots) x where x is not null) then
      raise exception 'The transfer market is closed, so players can''t be bought or sold right now. You can still swap with your bench and change captain.';
    end if;
  end if;
  select split_part(x, '--', 1) into bad
  from unnest(new.slots) as x
  where x is not null
  group by split_part(x, '--', 1)
  having count(*) > 2
  limit 1;
  if bad is not null then
    raise exception 'Invalid Squad: Maximum 2 players permitted from a single WINter team.';
  end if;
  if (select count(x) from unnest(new.slots) x where x is not null)
     <> (select count(distinct x) from unnest(new.slots) x where x is not null) then
    raise exception 'A player can only be picked once.';
  end if;
  if exists (select 1 from unnest(new.slots) x where x is not null
             and not exists (select 1 from public.player_prices pp where pp.player_id = x)) then
    raise exception 'That squad has a player without a price.';
  end if;
  for i in 1..5 loop
    p := new.slots[i];
    if p is not null then
      select pos into ppos from public.player_prices where player_id = p;
      if ppos is distinct from wanted[i] then
        raise exception 'A % can''t play in the % slot.', coalesce(ppos, '?'), wanted[i];
      end if;
    end if;
  end loop;
  select coalesce(sum(pp.price), 0) into total
  from unnest(new.slots) x join public.player_prices pp on pp.player_id = x;
  if total > 100 then
    raise exception 'Over budget: this squad costs %M, the limit is 100M.', total;
  end if;
  if new.captain is not null and not coalesce(new.captain = any(array_remove(new.slots, null)), false) then
    raise exception 'Your captain must be one of your squad''s players.';
  end if;
  if new.captain is null and exists (select 1 from unnest(new.slots) x where x is not null) then
    raise exception 'Pick a captain before saving: tap a player''s shirt.';
  end if;
  if new.locked and (select count(x) from unnest(new.slots) x where x is not null) < 7 then
    raise exception 'Only a complete 7-player squad can be locked.';
  end if;
  new.updated_at := now();
  return new;
end;
$$;
