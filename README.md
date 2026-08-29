# BAKTUS ÉLECT SARLU — Site officiel

Version corrigée pour GitHub Pages :
`https://baktuselect-serv.github.io/baktuselect-serv/`

## Structure obligatoire

Le dépôt doit conserver exactement cette structure :

```text
/
├── index.html
├── 404.html
├── README.md
├── IMAGE-MANIFEST.md
├── supabase-config.js
├── supabase-schema.sql
└── assets/
    ├── logo-officiel.png
    └── image*.jpg
```

**Important :** ne pas envoyer uniquement les fichiers image à la racine du dépôt. Le dossier `assets/` doit rester présent.

## Correction des images
Les chemins d’images sont centralisés avec `assetUrl()` et utilisent `/baktuselect-serv/assets/` sur GitHub Pages. Les images statiques du HTML utilisent `assets/...`, ce qui conserve le bon chemin relatif sous la base GitHub Pages.

## Hero
Titre officiel :
**L’EXCELLENCE TECHNIQUE, AU CŒUR DE VOS PROJETS.**

## Langues
Le sélecteur conserve la langue choisie dans `localStorage` et prend en charge : Français, English, Lingala, Kikongo, Swahili et Tshiluba.

## Photo 1000725427.jpg
Cette photo n’était pas présente parmi les fichiers disponibles lors de la préparation de cette version. Elle ne doit pas être remplacée par une image fictive. Ajouter le fichier original dans `assets/` lorsqu’il sera fourni.
