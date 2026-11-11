-- WINter Fantasy: entry approval.
-- Run once in Supabase → SQL Editor (after schema.sql and 002).
-- New managers start as "pending". Only organizers can approve or reject them,
-- and only approved managers can save a squad.

alter table public.profiles
  add column if not exists status text not null default 'pending'
  check (status in ('pending', 'approved', 'rejected'));

-- Organizers are in automatically.
update public.profiles set status = 'approved'
where id in (select user_id from public.admins);

create or replace function public.is_approved() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and status = 'approved');
$$;
grant execute on function public.is_approved() to authenticated;

-- Nobody but an organizer can set or change a status. New rows always start pending.
create or replace function public.guard_profile_status() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    if not public.is_admin() then new.status := 'pending'; end if;
  elsif new.status is distinct from old.status and not public.is_admin() then
    new.status := old.status;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_status_guard on public.profiles;
create trigger profiles_status_guard before insert or update on public.profiles
for each row execute function public.guard_profile_status();

-- Organizers can update any manager's profile (to approve or reject).
drop policy if exists "admins manage profiles" on public.profiles;
create policy "admins manage profiles" on public.profiles for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Only approved managers can save a squad.
drop policy if exists "create own squad" on public.squads;
create policy "create own squad" on public.squads for insert to authenticated
  with check (user_id = auth.uid() and public.squads_open() and public.is_approved());
drop policy if exists "edit own open squad" on public.squads;
create policy "edit own open squad" on public.squads for update to authenticated
  using (user_id = auth.uid() and not locked and public.squads_open() and public.is_approved())
  with check (user_id = auth.uid() and public.squads_open() and public.is_approved());

-- Organizer-only member list, with emails (other players never see emails).
create or replace function public.admin_members()
returns table (
  id uuid, team_name text, manager_name text, favorite_team text, status text,
  email text, google_name text, created_at timestamptz, players_picked int, is_organizer boolean
)
language sql stable security definer set search_path = public as $$
  select p.id, p.team_name, p.manager_name, p.favorite_team, p.status,
         u.email::text,
         coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', '')::text,
         p.created_at,
         coalesce(cardinality(array_remove(s.slots, null)), 0)::int,
         exists (select 1 from public.admins a where a.user_id = p.id)
  from public.profiles p
  join auth.users u on u.id = p.id
  left join public.squads s on s.user_id = p.id
  where public.is_admin()
  order by p.created_at;
$$;
revoke all on function public.admin_members() from public, anon;
grant execute on function public.admin_members() to authenticated;
