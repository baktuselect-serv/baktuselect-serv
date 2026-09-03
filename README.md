# BAKTUS ÉLECT SARLU — version corrigée

Cette version corrige l'affichage des réalisations et sécurise la connexion administrateur.

## Photos
- Les 13 réalisations sont conservées.
- Les 34 photos réellement disponibles dans les éléments fournis sont toutes référencées et affichées.
- Toutes les photos d'une réalisation sont visibles directement dans sa carte et dans la fenêtre « Voir le projet ».
- Aucune image fictive « Photo à venir » n'est affichée lorsqu'une photo existe.
- Les images utilisent `object-fit: contain` pour éviter les recadrages et préserver leur ratio.

## Connexion administrateur
La connexion utilise exclusivement Supabase Auth (`signInWithPassword`). Aucun mot de passe n'est stocké dans le HTML/JavaScript.

Si votre identifiant est correct mais que le mot de passe est refusé, il faut réinitialiser le mot de passe du compte dans Supabase Auth > Users, puis se reconnecter. Le code du site ne peut pas connaître ni modifier un mot de passe Supabase sans accès administrateur sécurisé.

## Déploiement GitHub Pages
Remplacer les fichiers du dépôt par ceux de cette archive, en conservant le dossier `assets/` et `supabase-config.js` à la racine.

## Administration finale
- Exécuter `supabase-schema.sql` dans le SQL Editor Supabase.
- Créer l'utilisateur Auth administrateur puis insérer son UUID dans `public.admin_users`.
- Le tableau de bord vérifie `public.is_admin()` avant d'afficher les données privées.
- Les visites sont anonymisées : aucun IP n'est enregistré. La table `site_visits` est lisible uniquement par les administrateurs.
