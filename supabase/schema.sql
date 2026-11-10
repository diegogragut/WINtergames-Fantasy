-- WINter Fantasy database
-- Run this once in Supabase: Dashboard → SQL Editor → New query → paste → Run.

-- ---------- Tables ----------

-- One row per manager, created on first sign-in ("Create your team").
create table if not exists public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  team_name     text not null check (char_length(team_name) between 3 and 32),
  manager_name  text not null check (char_length(manager_name) between 2 and 40),
  favorite_team text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- One squad per manager. slots = 7 player ids: 0 GK, 1-2 DEF, 3 MID, 4 FWD, 5-6 bench.
create table if not exists public.squads (
  user_id    uuid primary key references public.profiles (id) on delete cascade,
  slots      text[] not null default array[null,null,null,null,null,null,null]::text[],
  locked     boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint seven_slots check (cardinality(slots) = 7)
);

-- Match results, entered by the organizer.
create table if not exists public.match_stats (
  match_id   text primary key,          -- m01 … m12
  home_score int not null default 0 check (home_score >= 0),
  away_score int not null default 0 check (away_score >= 0),
  gk_home    text,                      -- player id of the home goalkeeper
  gk_away    text,
  events     jsonb not null default '{}'::jsonb,  -- { "<playerId>": { "g": 1, "a": 0, "y": 0, "r": 0 } }
  updated_at timestamptz not null default now()
);

-- Player positions, set by the organizer. Players without a row can fill any slot.
create table if not exists public.positions (
  player_id text primary key,
  pos       text not null check (pos in ('GK','DEF','MID','FWD'))
);

-- Organizers. Add yourself after your first sign-in (see README).
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);

-- ---------- Rules enforced by the database ----------

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- First kick-off: Nov 12, 19:00 Costa Rica time. No squad changes after this.
create or replace function public.squads_open() returns boolean
language sql stable as $$
  select now() < timestamptz '2026-11-12 19:00:00-06';
$$;

-- Max 2 players per WINter team, no duplicates. Player ids look like "<team-slug>--<name-slug>".
create or replace function public.check_squad() returns trigger
language plpgsql as $$
declare
  bad text;
begin
  select split_part(p, '--', 1) into bad
  from unnest(new.slots) as p
  where p is not null
  group by split_part(p, '--', 1)
  having count(*) > 2
  limit 1;
  if bad is not null then
    raise exception 'Invalid Squad: Maximum 2 players permitted from a single WINter team.';
  end if;
  if (select count(p) from unnest(new.slots) p where p is not null)
     <> (select count(distinct p) from unnest(new.slots) p where p is not null) then
    raise exception 'A player can only be picked once.';
  end if;
  if new.locked and (select count(p) from unnest(new.slots) p where p is not null) < 7 then
    raise exception 'Only a complete 7-player squad can be locked.';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists squads_check on public.squads;
create trigger squads_check before insert or update on public.squads
for each row execute function public.check_squad();

-- ---------- Row level security ----------

alter table public.profiles    enable row level security;
alter table public.squads      enable row level security;
alter table public.match_stats enable row level security;
alter table public.positions   enable row level security;
alter table public.admins      enable row level security;

-- Everyone signed in can read the league.
drop policy if exists "read profiles" on public.profiles;
create policy "read profiles" on public.profiles for select to authenticated using (true);
drop policy if exists "read squads" on public.squads;
create policy "read squads" on public.squads for select to authenticated using (true);
drop policy if exists "read stats" on public.match_stats;
create policy "read stats" on public.match_stats for select to authenticated using (true);
drop policy if exists "read positions" on public.positions;
create policy "read positions" on public.positions for select to authenticated using (true);
drop policy if exists "read own admin row" on public.admins;
create policy "read own admin row" on public.admins for select to authenticated using (user_id = auth.uid());

-- Each manager creates and edits only their own team profile.
drop policy if exists "create own profile" on public.profiles;
create policy "create own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "edit own profile" on public.profiles;
create policy "edit own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Each manager saves only their own squad, only before kick-off, and never after locking it.
drop policy if exists "create own squad" on public.squads;
create policy "create own squad" on public.squads for insert to authenticated
  with check (user_id = auth.uid() and public.squads_open());
drop policy if exists "edit own open squad" on public.squads;
create policy "edit own open squad" on public.squads for update to authenticated
  using (user_id = auth.uid() and not locked and public.squads_open())
  with check (user_id = auth.uid() and public.squads_open());

-- Only organizers enter results and positions.
drop policy if exists "admins write stats" on public.match_stats;
create policy "admins write stats" on public.match_stats for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admins write positions" on public.positions;
create policy "admins write positions" on public.positions for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------- Live updates ----------
-- Lets the app refresh the table and points as soon as anyone saves.
do $$
begin
  begin alter publication supabase_realtime add table public.squads;      exception when others then null; end;
  begin alter publication supabase_realtime add table public.match_stats; exception when others then null; end;
  begin alter publication supabase_realtime add table public.profiles;    exception when others then null; end;
  begin alter publication supabase_realtime add table public.positions;   exception when others then null; end;
end $$;
