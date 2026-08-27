# BAKTUS ÉLECT SARLU — site officiel

Projet préparé pour GitHub Pages sur le dépôt `baktuselect-serv/baktuselect-serv`.

Production GitHub Pages : `https://baktuselect-serv.github.io/baktuselect-serv/`
Domaine préparé : ``

## Structure
- `index.html` : site public + interface Admin interne
- `404.html` : secours de routage GitHub Pages
- `CNAME` : domaine personnalisé préparé
- `assets/` : logo officiel et photos disponibles
- `supabase-config.js` : URL/anon key Supabase à renseigner
- `supabase-schema.sql` : schéma et RLS

## Important
Le fichier `supabase-config.js` contient volontairement des valeurs `YOUR_...` tant que les identifiants publics du projet Supabase réel ne sont pas disponibles. Ne jamais mettre de `service_role` ou mot de passe dans le frontend.

Les réalisations dont une photo ne peut pas être attribuée avec certitude restent sans photo et sont signalées « Photo à classer ».
