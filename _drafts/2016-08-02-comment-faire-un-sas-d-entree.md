---
layout: post
categories:
- Tutoriel
tags: []
title: "Comment faire un sas d'entré"
cover: /Assets/uploads/2016/04/frozentundra.jpg
author: purexo
---

Bonjour tout le monde, j'ai enfin fini Starbound mais avant de récupéré l'avant dernier artifact je me suis fait une petite pause colonie. C'est vraiment un système cool du jeu et je regrette de ne pas m'y être mis plus tôt.

Durant la gestion de ma colonie j'ai été quelque peut embété de mes colons qui laissait les portes ouvertes et s'étonnait de ce faire attaquer par des vilains monstres. Du coup j'ai réfléchis à un système de sas pour pas être embetté.

Ici le sas est simple, c'est juste un système de porte en miroir inversé, c'est à dire que une seule porte peut être ouverte en même temps. Ce n'est pas un montage "complexe" qui fait intervenir l'eau et ne pourras pas être utilisé en l'état pour vos bases sous marines.

J'en ai imaginé deux assez similaire, l'un est basé sur les proximity sensor, l'autre sur des boutons aux sol/plaque de pression
celui sur les proximity sensor est plus simple car un seul suffit par porte alors que les boutons il en faut un de chaque portes

## Sas automatisé - proximity sensor

<blockquote class="imgur-embed-pub" lang="en" data-id="a/F6d5h"><a href="//imgur.com/F6d5h">Starbound-Fr - Tuto sas proximity</a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>

#### 1. La base, l'emplacement
On va poser tout ce qu'il faut pour faire un petit sas. Ici j'ai utilisé des durasteel door, mais n'importe quelle porte de n'importe quelle épaisseur fera l'affaire.

En largeur entre les deux portes j'ai pris 6x2 blocs d'espace, vous pouvez descendre jusqu'a 4x2 au dela les deux proximity sensor vous detecterons et le système sera buggé. Pour plus de confort (du à la latence des proximity sensor) hésitez pas à espacer encore plus les deux portes ;-)

On creuse en dessous pour "cacher" les circuits

#### 2. On place les composants
Un proximity sensor en dessous de chaque porte (le plus proche possible de la porte pour que ça fonctionne), un AND et un NOT par porte.

Le AND c'est le plus proche de la porte, le NOT c'est ceux du milieu.

#### 3. On relie le tout
En bleu les entrées, en rouge les sorties.

On va ce fixer une nomenclature pour tout ce bazarre (et pas de blague en commentaire pour les noms que ça génère, merci...):

- PG : Porte de Gauche
- PD : Porte de Droite
- PSG : Proximity Sensor de Gauche
- PSD : Proximity Sensor de Droite
- AG : AND de Gauche
- AD : AND de Droite
- NG : NOT de Gauche
- ND : NOT de Droite

À ces composants on rajoutera des petites lettres :

- o pour Output (sortie)
- i pour Input (entrée)
  - ih pour Input Haut
  - ib pour Input Bas

Voici le mappage :

```
// circuit de la porte de gauche
PSGs -> AGib
PDs -> NGi
NGs -> AGih
AGis -> PGi

// circuit de la porte de droite
PSDs -> ADib
PGs -> NDi
NDs -> ADih
ADis -> PDi
```
