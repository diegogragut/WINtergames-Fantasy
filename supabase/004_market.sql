-- WINter Fantasy: official player market (prices by rating) and the 100M budget.
-- Run once in Supabase → SQL Editor (after schema.sql, 002 and 003).
-- Squads: 1 GK, 2 CB, 2 ST + 2 bench (any position). 7 players, max 100M.

create table if not exists public.player_prices (
  player_id text primary key,
  pos       text not null check (pos in ('GK','CB','ST')),
  rating    int  not null check (rating between 1 and 10),
  price     numeric(5,1) not null check (price >= 0)
);
alter table public.player_prices enable row level security;
drop policy if exists "read prices" on public.player_prices;
create policy "read prices" on public.player_prices for select to authenticated using (true);
grant select on public.player_prices to authenticated;

insert into public.player_prices (player_id, pos, rating, price) values
  ('garbanzo-fc--agustin-mendez', 'CB', 4, 6),
  ('garbanzo-fc--alejandro-garro', 'ST', 5, 8),
  ('garbanzo-fc--alejandro-vasquez', 'ST', 6, 10),
  ('garbanzo-fc--diego-gutierrez', 'GK', 4, 6),
  ('garbanzo-fc--felipe-gomez', 'ST', 2, 2),
  ('garbanzo-fc--gabriel-mata', 'CB', 5, 8),
  ('garbanzo-fc--nicholas-cook', 'ST', 9, 21),
  ('garbanzo-fc--patrick-ferris', 'ST', 6, 10),
  ('garbanzo-fc--santiago-mora', 'CB', 6, 10),
  ('garbanzo-fc--stefano-battaglini', 'CB', 2, 2),
  ('la-granja-fc--david-cascante', 'CB', 2, 2),
  ('la-granja-fc--david-sandi', 'CB', 2, 2),
  ('la-granja-fc--diego-saldana', 'CB', 2, 2),
  ('la-granja-fc--dylan-alfaro', 'CB', 3, 4),
  ('la-granja-fc--felipe-coronas', 'ST', 4, 6),
  ('la-granja-fc--gabriel-soto', 'CB', 2, 2),
  ('la-granja-fc--emiliano-guier', 'ST', 3, 4),
  ('la-granja-fc--jan-saravia', 'CB', 2, 2),
  ('la-granja-fc--jose-miguel', 'GK', 2, 2),
  ('la-granja-fc--kai-andre', 'CB', 3, 4),
  ('limon-2000--alejandro-ulloa', 'CB', 5, 8),
  ('limon-2000--andres-quesada', 'ST', 6, 10),
  ('limon-2000--diego-orozco', 'CB', 2, 2),
  ('limon-2000--felipe-campos', 'GK', 5, 8),
  ('limon-2000--felipe-pena', 'ST', 8, 17),
  ('limon-2000--gianluca-fonseca', 'CB', 5, 8),
  ('limon-2000--nicolas-rivera', 'CB', 4, 6),
  ('limon-2000--santiago-jimenez', 'ST', 6, 10),
  ('limon-2000--santiago-mena', 'CB', 3, 4),
  ('ayotazo-fc--alan-woodbridge', 'CB', 8, 17),
  ('ayotazo-fc--alejandro-madrigal', 'GK', 5, 8),
  ('ayotazo-fc--antonio-jimenez', 'ST', 9, 21),
  ('ayotazo-fc--ayote', 'ST', 9, 21),
  ('ayotazo-fc--emiliano-crivelli', 'CB', 4, 6),
  ('ayotazo-fc--ignacio-bogantes', 'ST', 7, 13),
  ('ayotazo-fc--matias-alfaro', 'ST', 10, 25),
  ('ayotazo-fc--sergio-sauma', 'ST', 10, 25),
  ('sin-pulmon--gafas', 'CB', 2, 2),
  ('sin-pulmon--alberto-pacheco', 'ST', 5, 8),
  ('sin-pulmon--alessandro-de-carlo', 'CB', 4, 6),
  ('sin-pulmon--antonio-fernandez', 'CB', 4, 6),
  ('sin-pulmon--daniel-bolanos', 'GK', 2, 2),
  ('sin-pulmon--diego-granados', 'ST', 5, 8),
  ('sin-pulmon--emiliano-mendez', 'ST', 3, 4),
  ('sin-pulmon--ignacio-garnier', 'ST', 3, 4),
  ('sin-pulmon--julian-garnier', 'ST', 3, 4),
  ('sin-pulmon--sebastian-madrigal', 'CB', 5, 8),
  ('sin-pulmon--felipe-volio', 'CB', 4, 6),
  ('zopilotes-fc--alejandro-soto', 'CB', 3, 4),
  ('zopilotes-fc--andres-rodriguez', 'CB', 2, 2),
  ('zopilotes-fc--antonio-carballo', 'CB', 2, 2),
  ('zopilotes-fc--daniel-coto', 'CB', 2, 2),
  ('zopilotes-fc--ignacio-jaramillo', 'CB', 3, 4),
  ('zopilotes-fc--julian-regueyra', 'CB', 3, 4),
  ('zopilotes-fc--luis-fernando-cedeno', 'CB', 2, 2),
  ('zopilotes-fc--martin-salom', 'CB', 2, 2),
  ('guadamuz--emilio-artavia', 'GK', 5, 8),
  ('guadamuz--felipe-ferraro', 'CB', 5, 8),
  ('guadamuz--jupa-popi', 'CB', 3, 4),
  ('guadamuz--luis-carlos', 'CB', 4, 6),
  ('guadamuz--oscar-saborio', 'CB', 5, 8),
  ('guadamuz--raymond-semaan', 'CB', 6, 10),
  ('guadamuz--sebastian-solera', 'CB', 3, 4),
  ('jogobonito--andres-rucavado', 'GK', 5, 8),
  ('jogobonito--ian-goldberg', 'ST', 10, 25),
  ('jogobonito--ignacio-child', 'CB', 10, 25),
  ('jogobonito--javier-sanabria', 'CB', 7, 13),
  ('jogobonito--luciano-soto', 'ST', 9, 21),
  ('jogobonito--randy-xirinachs', 'GK', 5, 8),
  ('limon-stars--andres-soto', 'ST', 4, 6),
  ('limon-stars--toto-jay', 'ST', 8, 17),
  ('limon-stars--emilio-atmella', 'CB', 7, 13),
  ('limon-stars--eric-brenes', 'CB', 5, 8),
  ('limon-stars--luciano-segnini', 'ST', 5, 8),
  ('limon-stars--patrick-van-der-laat', 'CB', 9, 21),
  ('brasimoreros--agustin-pacheco', 'GK', 5, 8),
  ('brasimoreros--eduardo-odio', 'ST', 6, 10),
  ('brasimoreros--julian-segura', 'CB', 8, 17),
  ('brasimoreros--marco-olivo', 'CB', 8, 17),
  ('brasimoreros--martin-castro', 'CB', 5, 8),
  ('brasimoreros--stefan-matzen', 'ST', 8, 17),
  ('brasimoreros--tomas-quijano', 'ST', 5, 8),
  ('guarani-fc--alberto-jimenez', 'CB', 3, 4),
  ('guarani-fc--alessio-riggioni', 'ST', 7, 13),
  ('guarani-fc--bogis', 'ST', 6, 10),
  ('guarani-fc--diego-quiros', 'ST', 3, 4),
  ('guarani-fc--diego-ruiz', 'CB', 7, 13),
  ('guarani-fc--emiliano-silva', 'ST', 8, 17),
  ('guarani-fc--ignacio-rivera', 'ST', 4, 6),
  ('guarani-fc--juanpi-chavarria', 'CB', 5, 8),
  ('guarani-fc--nono-guzman', 'CB', 7, 13),
  ('guarani-fc--ruben-garita', 'CB', 5, 8),
  ('pasion-fc--campanazo', 'CB', 3, 4),
  ('pasion-fc--franco-hernandez', 'CB', 4, 6),
  ('pasion-fc--garcia', 'CB', 3, 4),
  ('pasion-fc--gaza', 'GK', 4, 6),
  ('pasion-fc--hacha-mango', 'CB', 5, 8),
  ('pasion-fc--matias-quiros', 'CB', 3, 4),
  ('pasion-fc--mosquito', 'CB', 3, 4),
  ('pasion-fc--pipe-bersoza', 'ST', 5, 8),
  ('pasion-fc--roberto-zamora', 'ST', 8, 17)
on conflict (player_id) do update set pos = excluded.pos, rating = excluded.rating, price = excluded.price;

-- The second Antonio Jimenez (Limon Stars) is listed as Toto Jay.
delete from public.player_prices where player_id = 'limon-stars--antonio-jimenez';

-- Squad rules: max 2 per WINter team, no duplicates, every pick priced,
-- starters in the right position, total cost within 100M, only complete squads lock.
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
  if new.locked and (select count(x) from unnest(new.slots) x where x is not null) < 7 then
    raise exception 'Only a complete 7-player squad can be locked.';
  end if;
  new.updated_at := now();
  return new;
end;
$$;
