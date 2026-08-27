# BAKTUS ÉLECT SARLU — site officiel

Projet statique préparé pour GitHub Pages sur le dépôt `baktuselect-serv/baktuselect-serv`.

Production GitHub Pages : `https://baktuselect-serv.github.io/baktuselect-serv/`

## Structure
- `index.html` : site public + interface Admin interne
- `404.html` : secours de routage GitHub Pages
- `assets/` : logo officiel et 13 photos issues du dossier source
- `supabase-config.js` : configuration publique Supabase à conserver/configurer dans le dépôt de production
- `supabase-schema.sql` : schéma et RLS

## Images
Les chemins d’images utilisent explicitement la base GitHub Pages `/baktuselect-serv/assets/` afin d’éviter les références cassées après publication. Les 13 photos sont associées aux 13 réalisations dans le même ordre que le dossier institutionnel source : image3 → réalisation 01, image4 → 02, …, image14 → 13.

## Hero
Le titre officiel est : `L’EXCELLENCE TECHNIQUE, AU CŒUR DE VOS PROJETS.`

## Supabase
Ne jamais mettre de `service_role`, de mot de passe ou de secret privé dans le frontend. Utiliser uniquement la clé publique `anon`/`public` ou la nouvelle clé publishable selon la configuration Supabase retenue.
