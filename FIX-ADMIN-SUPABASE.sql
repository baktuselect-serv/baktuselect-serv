-- CORRECTION RAPIDE — accès administrateur BAKTUS ÉLECT
-- À exécuter une seule fois dans Supabase > SQL Editor.
-- Le compte doit déjà exister dans Supabase Authentication.

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

-- Autorise la vérification de l'administrateur connecté.
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admin_users where user_id = auth.uid()); $$;

select public.bootstrap_admin();
select public.is_admin();

-- Compatibilité avec les anciennes versions de la table site_visits.
ALTER TABLE public.site_visits ADD COLUMN IF NOT EXISTS visited_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE public.site_visits ADD COLUMN IF NOT EXISTS page text NOT NULL DEFAULT '/';
ALTER TABLE public.site_visits ADD COLUMN IF NOT EXISTS browser text;
NOTIFY pgrst, 'reload schema';
