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

Si l'adresse `baktuselect@gmail.com` est correcte mais que le mot de passe est refusé, il faut réinitialiser le mot de passe du compte dans Supabase Auth > Users, puis se reconnecter. Le code du site ne peut pas connaître ni modifier un mot de passe Supabase sans accès administrateur sécurisé.

## Déploiement GitHub Pages
Remplacer les fichiers du dépôt par ceux de cette archive, en conservant le dossier `assets/` et `supabase-config.js` à la racine.
