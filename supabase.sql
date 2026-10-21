-- Run this in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.daily_meals (
  id uuid primary key default gen_random_uuid(),
  person text not null check (person in ('Vincent','Eileen')),
  meal_date date not null,
  amount numeric(10,2) not null check (amount > 0),
  note text check (char_length(coalesce(note,'')) <= 120),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.monthly_sheets (
  sheet_name text primary key,
  sheet_order integer not null default 0,
  rows jsonb not null default '[]'::jsonb,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

alter table public.app_admins enable row level security;
alter table public.daily_meals enable row level security;
alter table public.monthly_sheets enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.app_admins where user_id = auth.uid()); $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- Admin membership itself cannot be changed by ordinary app users.
drop policy if exists "Admins can read admin list" on public.app_admins;
create policy "Admins can read admin list" on public.app_admins for select to authenticated using (public.is_admin());

drop policy if exists "Signed-in users can read meals" on public.daily_meals;
create policy "Signed-in users can read meals" on public.daily_meals for select to authenticated using (true);
drop policy if exists "Signed-in users can add meal entries only" on public.daily_meals;
create policy "Signed-in users can add meal entries only" on public.daily_meals for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "Admins can update meals" on public.daily_meals;
create policy "Admins can update meals" on public.daily_meals for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins can delete meals" on public.daily_meals;
create policy "Admins can delete meals" on public.daily_meals for delete to authenticated using (public.is_admin());

drop policy if exists "Signed-in users can read bill sheets" on public.monthly_sheets;
create policy "Signed-in users can read bill sheets" on public.monthly_sheets for select to authenticated using (true);
drop policy if exists "Admins can insert bill sheets" on public.monthly_sheets;
create policy "Admins can insert bill sheets" on public.monthly_sheets for insert to authenticated with check (public.is_admin());
drop policy if exists "Admins can update bill sheets" on public.monthly_sheets;
create policy "Admins can update bill sheets" on public.monthly_sheets for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins can delete bill sheets" on public.monthly_sheets;
create policy "Admins can delete bill sheets" on public.monthly_sheets for delete to authenticated using (public.is_admin());

grant select on public.app_admins to authenticated;
grant select, insert, update, delete on public.daily_meals to authenticated;
grant select, insert, update, delete on public.monthly_sheets to authenticated;
