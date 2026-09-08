-- BAKTUS ÉLECT SARLU — correction des formulaires publics
-- À exécuter une seule fois dans Supabase > SQL Editor.
-- Les visiteurs peuvent ENVOYER une demande, mais ne peuvent pas lire les demandes.

create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(),
  client text not null,
  company text,
  address text not null,
  phone text not null,
  email text,
  site_type text,
  services text[] not null default '{}',
  description text not null default '',
  responsable text,
  requested_date date,
  requested_time time,
  status text not null default 'Nouvelle',
  technician_notes text,
  diagnosis text,
  recommendations text,
  inspection_fee numeric,
  travel_fee numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  company text,
  phone text not null,
  email text,
  service text,
  description text not null default '',
  status text not null default 'Nouvelle',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.inspections enable row level security;
alter table public.quotes enable row level security;

-- Supprime les anciennes politiques d'insertion pour éviter les doublons de nom.
drop policy if exists "public insert inspections" on public.inspections;
drop policy if exists "public insert quotes" on public.quotes;

create policy "public insert inspections" on public.inspections
for insert to anon, authenticated with check (true);

create policy "public insert quotes" on public.quotes
for insert to anon, authenticated with check (true);

-- Fonctions sécurisées : elles permettent uniquement la création d'une demande.
create or replace function public.submit_inspection(
  p_client text,
  p_company text,
  p_address text,
  p_phone text,
  p_email text,
  p_site_type text,
  p_services text[],
  p_description text,
  p_responsable text,
  p_requested_date date,
  p_requested_time time
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare new_id uuid;
begin
  if nullif(trim(p_client),'') is null then raise exception 'Nom / entreprise requis'; end if;
  if nullif(trim(p_address),'') is null then raise exception 'Adresse d’intervention requise'; end if;
  if nullif(trim(p_phone),'') is null then raise exception 'Téléphone requis'; end if;
  insert into public.inspections(client,company,address,phone,email,site_type,services,description,responsable,requested_date,requested_time)
  values(trim(p_client),nullif(trim(p_company),''),trim(p_address),trim(p_phone),nullif(trim(p_email),''),nullif(trim(p_site_type),''),coalesce(p_services,'{}'),coalesce(p_description,''),nullif(trim(p_responsable),''),p_requested_date,p_requested_time)
  returning id into new_id;
  return new_id;
end;
$$;

create or replace function public.submit_quote(
  p_name text,
  p_company text,
  p_phone text,
  p_email text,
  p_service text,
  p_description text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare new_id uuid;
begin
  if nullif(trim(p_name),'') is null then raise exception 'Nom requis'; end if;
  if nullif(trim(p_phone),'') is null then raise exception 'Téléphone requis'; end if;
  if nullif(trim(p_description),'') is null then raise exception 'Description requise'; end if;
  insert into public.quotes(name,company,phone,email,service,description)
  values(trim(p_name),nullif(trim(p_company),''),trim(p_phone),nullif(trim(p_email),''),nullif(trim(p_service),''),trim(p_description))
  returning id into new_id;
  return new_id;
end;
$$;

revoke all on function public.submit_inspection(text,text,text,text,text,text,text[],text,text,date,time) from public;
revoke all on function public.submit_quote(text,text,text,text,text,text) from public;
grant execute on function public.submit_inspection(text,text,text,text,text,text,text[],text,text,date,time) to anon, authenticated;
grant execute on function public.submit_quote(text,text,text,text,text,text) to anon, authenticated;

-- Les demandes restent privées : lecture/modification uniquement par un administrateur.
drop policy if exists "admins manage inspections" on public.inspections;
drop policy if exists "admins manage quotes" on public.quotes;
create policy "admins manage inspections" on public.inspections for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins manage quotes" on public.quotes for all to authenticated using (public.is_admin()) with check (public.is_admin());

notify pgrst, 'reload schema';
