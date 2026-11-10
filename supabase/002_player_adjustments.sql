-- WINter Fantasy: organizer point adjustments.
-- Run once in Supabase → SQL Editor (after schema.sql).
-- Organizers can add or remove bonus/penalty points for any player, with a reason.
-- Everyone signed in can see them; only organizers can change them.

create table if not exists public.player_adjustments (
  id         bigint generated always as identity primary key,
  player_id  text not null,
  points     int  not null check (points between -50 and 50 and points <> 0),
  reason     text check (reason is null or char_length(reason) <= 80),
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.player_adjustments enable row level security;

drop policy if exists "read adjustments" on public.player_adjustments;
create policy "read adjustments" on public.player_adjustments
  for select to authenticated using (true);

drop policy if exists "admins add adjustments" on public.player_adjustments;
create policy "admins add adjustments" on public.player_adjustments
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins remove adjustments" on public.player_adjustments;
create policy "admins remove adjustments" on public.player_adjustments
  for delete to authenticated using (public.is_admin());

grant select, insert, delete on public.player_adjustments to authenticated;
grant usage, select on sequence public.player_adjustments_id_seq to authenticated;

do $$
begin
  begin alter publication supabase_realtime add table public.player_adjustments; exception when others then null; end;
end $$;
