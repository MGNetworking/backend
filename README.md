## Table of contents

* [General info](#general-info)
* [Setup](#setup)
  * [Before Run](#Before-Run)
  * [Submodule](#Submodule)

## General info

Ce projet est le regroupement plusieurs sous projet Spring boot. Ces projets sont micro 
service pour la gestion du blog possèdent le nom de domain : **ghoverblog**

## Setup

### Before-Run 
Le script de lancement `init.sh`, lance d'autre script. Certain de ces scripts sont exécutables avec le Shell 
git, Mais pas tous. 
Par exemple le script `version.sh`, il a besoin d'installer l'utilitaire `xmlstarlet` qui fonctionne sur 
uniquement dans les environnements `linux`.

### Submodule
La commande `git submodule init`   
est utilisée pour initialiser les sous-modules d'un référentiel Git
Lorsque vous exécutez cette commande, Git recherche les informations des sous-modules
dans le fichier `.gitmodules` du référentiel principal.
Elle configure les sous-modules enregistrés dans le fichier `.gitmodules` pour être suivis
et utilisés dans le référentiel principal.

Cependant, elle ne récupère pas automatiquement les fichiers des sous-modules.
C'est pourquoi vous devez également exécuter la commande `git submodule update` pour obtenir les fichiers réels des
sous-modules.

```shell
git submodule init
```

La commande `git submodule update`   
est utilisée pour mettre à jour les fichiers des sous-modules
après leur initialisation.
Lorsque vous exécutez cette commande, Git récupère les fichiers des sous-modules en fonction des informations
enregistrées dans le
référentiel principal.

Elle récupère les révisions spécifiées pour les sous-modules
et place les fichiers des sous-modules aux emplacements appropriés dans le répertoire
du référentiel principal. Cela vous permet d'obtenir les fichiers actuels
des sous-modules et de les utiliser dans votre projet principal.

```shell
git submodule update
```

Pour lancer le docker compose principale, vous devez utiliser le script `init.sh`
Ce script contient le processus complet permettent d'initialiser les variables contenus
dans le fichier .env situé à la racine du projet.

Il permet aussi de déterminer l'IP local de la machine dans le but de localiser les
micro-services de configuration et de registre (eureka).

Il permet aussi de récupérer les versions des micro services pour la création des images

Exemple avec l'environnement de DEV :

```shell
./script/init.sh IP_DEV
```

Le paramètre `IP_DEV` correspond à la variable contenue dans le fichier `.env` .
Les autres paramètres sont les suivants :

* IP_PRE
* IP_PROD

Pour l'arrêt complet des services lancer par le docker compose principal

```shell
./script/down.sh 
```


