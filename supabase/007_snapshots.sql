-- WINter Fantasy: squad snapshots at every kick-off.
-- Run once in Supabase → SQL Editor (after 006_lock_control.sql).
-- At each match's kick-off, every saved squad is copied. That match's points use
-- the copy, so changes made later (after an organizer unlocks squads) only count
-- from the next match on.

-- Kick-off times. Keep in sync with FIXTURES in index.html.
create table if not exists public.fixtures (
  match_id text primary key,
  kickoff  timestamptz not null
);
insert into public.fixtures (match_id, kickoff) values
  ('m01', '2026-11-12 12:30:00-06'), ('m02', '2026-11-12 12:30:00-06'),
  ('m03', '2026-11-16 12:30:00-06'), ('m04', '2026-11-16 12:30:00-06'),
  ('m05', '2026-11-17 12:30:00-06'), ('m06', '2026-11-17 12:30:00-06'),
  ('m07', '2026-11-18 12:30:00-06'), ('m08', '2026-11-18 12:30:00-06'),
  ('m09', '2026-11-19 12:30:00-06'), ('m10', '2026-11-19 12:30:00-06'),
  ('m11', '2026-11-23 12:30:00-06'), ('m12', '2026-11-23 12:30:00-06')
on conflict (match_id) do update set kickoff = excluded.kickoff;

create table if not exists public.snapshot_runs (
  match_id text primary key references public.fixtures (match_id),
  taken_at timestamptz not null default now()
);

create table if not exists public.squad_snapshots (
  match_id text not null references public.fixtures (match_id),
  user_id  uuid not null references public.profiles (id) on delete cascade,
  slots    text[] not null,
  captain  text,
  taken_at timestamptz not null default now(),
  primary key (match_id, user_id)
);

alter table public.fixtures        enable row level security;
alter table public.snapshot_runs   enable row level security;
alter table public.squad_snapshots enable row level security;
drop policy if exists "read fixtures" on public.fixtures;
create policy "read fixtures" on public.fixtures for select to authenticated using (true);
drop policy if exists "read snapshot runs" on public.snapshot_runs;
create policy "read snapshot runs" on public.snapshot_runs for select to authenticated using (true);
drop policy if exists "read snapshots" on public.squad_snapshots;
create policy "read snapshots" on public.squad_snapshots for select to authenticated using (true);
grant select on public.fixtures, public.snapshot_runs, public.squad_snapshots to authenticated;

-- Copies every approved manager's squad for each match that has kicked off and
-- hasn't been copied yet. Safe to call any number of times.
create or replace function public.take_due_snapshots() returns int
language plpgsql security definer set search_path = public as $$
declare
  m record;
  n int := 0;
begin
  for m in
    select f.match_id from public.fixtures f
    where f.kickoff <= now()
      and not exists (select 1 from public.snapshot_runs r where r.match_id = f.match_id)
    order by f.kickoff, f.match_id
    for update skip locked
  loop
    insert into public.squad_snapshots (match_id, user_id, slots, captain)
    select m.match_id, s.user_id, s.slots, s.captain
    from public.squads s
    join public.profiles p on p.id = s.user_id and p.status = 'approved'
    on conflict (match_id, user_id) do nothing;
    insert into public.snapshot_runs (match_id) values (m.match_id) on conflict do nothing;
    n := n + 1;
  end loop;
  return n;
end;
$$;
revoke all on function public.take_due_snapshots() from public, anon;
grant execute on function public.take_due_snapshots() to authenticated;

-- Run the snapshot check every minute so each kick-off is captured on time.
create extension if not exists pg_cron;
select cron.schedule('winter-fantasy-snapshots', '* * * * *', 'select public.take_due_snapshots();');
