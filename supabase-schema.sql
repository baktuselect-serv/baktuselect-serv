-- BAKTUS ÉLECT SARLU — Supabase baseline
-- Run in Supabase SQL Editor after creating the project.
-- 1) Create the admin user in Supabase Auth with email baktuselect@gmail.com.
-- 2) Copy that user's UUID into admin_users.
-- 3) Never expose service_role in the frontend.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admin_users where user_id = auth.uid()); $$;

-- Bootstrap the known BAKTUS ÉLECT administrator after successful Auth login.
-- This runs server-side; the administrator email is never exposed in the website UI.
create or replace function public.bootstrap_admin()
returns boolean language plpgsql security definer set search_path = public, auth
as $$
begin
  if auth.uid() is null then return false; end if;
  if lower(coalesce(auth.jwt()->>'email','')) <> 'baktuselect@gmail.com' then return false; end if;
  insert into public.admin_users(user_id,email)
  values (auth.uid(), lower(auth.jwt()->>'email'))
  on conflict (user_id) do nothing;
  return true;
end;
$$;

revoke all on function public.bootstrap_admin() from public;
grant execute on function public.bootstrap_admin() to authenticated;

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null default '', image_url text,
  display_order integer not null default 0, active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(), title text not null, category text not null, description text not null default '', nature text not null default '', solutions text not null default '', results text not null default '', display_order integer not null default 0, published boolean not null default false, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.project_photos (
  id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade, storage_path text not null, alt_text text not null default '', display_order integer not null default 0, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(), client text not null, company text, address text not null, phone text not null, email text, site_type text, services text[] not null default '{}', description text not null, responsable text, requested_date date, requested_time time, status text not null default 'Nouvelle', technician_notes text, diagnosis text, recommendations text, inspection_fee numeric, travel_fee numeric, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(), name text not null, company text, phone text not null, email text, service text, description text not null, status text not null default 'Nouvelle', created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(), name text not null, phone text, email text, message text not null, read boolean not null default false, archived boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.social_settings (
  id uuid primary key default gen_random_uuid(), platform text unique not null, url text not null, active boolean not null default true, updated_at timestamptz not null default now()
);
create table if not exists public.translations (
  id uuid primary key default gen_random_uuid(), lang text not null, key text not null, value text not null, unique(lang,key)
);
create table if not exists public.site_visits (
  id uuid primary key default gen_random_uuid(),
  visitor_id text not null,
  visited_at timestamptz not null default now(),
  path text not null default '/',
  page text not null default '/',
  referrer text,
  browser text,
  language text,
  device text,
  screen_width integer
);

alter table public.admin_users enable row level security;
alter table public.services enable row level security;
alter table public.projects enable row level security;
alter table public.project_photos enable row level security;
alter table public.inspections enable row level security;
alter table public.quotes enable row level security;
alter table public.messages enable row level security;
alter table public.social_settings enable row level security;
alter table public.translations enable row level security;
alter table public.site_visits enable row level security;

-- Public visitors: only published/active public content.
create policy "public read active services" on public.services for select using (active = true);
create policy "public read published projects" on public.projects for select using (published = true);
create policy "public read published photos" on public.project_photos for select using (published = true);
create policy "public read active socials" on public.social_settings for select using (active = true);
create policy "public read translations" on public.translations for select using (true);

-- Public visitors may submit forms but cannot read them back.
create policy "public insert inspections" on public.inspections for insert with check (true);
create policy "public insert quotes" on public.quotes for insert with check (true);
create policy "public insert messages" on public.messages for insert with check (true);

create policy "public insert site visits" on public.site_visits for insert with check (true);
create policy "admins read site visits" on public.site_visits for select using (public.is_admin());

-- Admins may manage private/admin data.
create policy "admins manage admin_users" on public.admin_users for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage services" on public.services for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage projects" on public.projects for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage project_photos" on public.project_photos for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage inspections" on public.inspections for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage quotes" on public.quotes for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage messages" on public.messages for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage socials" on public.social_settings for all using (public.is_admin()) with check (public.is_admin());
create policy "admins manage translations" on public.translations for all using (public.is_admin()) with check (public.is_admin());

insert into public.social_settings(platform,url) values
('tiktok','https://www.tiktok.com/@baktus.elect?_r=1&_t=ZS-990qPrArNsA'),
('facebook','https://www.facebook.com/profile.php?id=61581769390140'),
('instagram','https://www.instagram.com/baktus_elect?igsi=eDlma2N2M2djbzVn'),
('whatsapp','https://whatsapp.com/channel/0029Vb6IGgm4CrflPTBU5a3B')
on conflict (platform) do update set url=excluded.url;

-- Storage bucket for project photos. Keep the bucket public only if the published gallery uses public URLs.
insert into storage.buckets (id,name,public) values ('project-photos','project-photos',true) on conflict (id) do nothing;
create policy "public read project photos" on storage.objects for select using (bucket_id='project-photos');
create policy "admins upload project photos" on storage.objects for insert with check (bucket_id='project-photos' and public.is_admin());
create policy "admins update project photos" on storage.objects for update using (bucket_id='project-photos' and public.is_admin()) with check (bucket_id='project-photos' and public.is_admin());
create policy "admins delete project photos" on storage.objects for delete using (bucket_id='project-photos' and public.is_admin());
