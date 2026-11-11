-- WINter Fantasy: captain (C), 2x points.
-- Run once in Supabase → SQL Editor (after 004_market.sql).
-- Each squad names one of its own players as captain. His points count double.
-- A squad with players can't be saved without a captain.

alter table public.squads add column if not exists captain text;

-- Same rules as 004, plus: the captain must be one of the squad's players.
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
