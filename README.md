## Table of contents

* [General info](#general-info)
* [Setup](#setup)
  * [Before Run](#Before-Run)
  * [Submodule](#Submodule)
  * [Run](#run)

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

```shell
git submodule init
```
Cette commande est utilisée pour initialiser les sous-modules d'un référentiel Git
Lorsque vous exécutez cette commande, Git recherche les informations des sous-modules
dans le fichier `.gitmodules` du référentiel principal.

Elle configure les sous-modules enregistrés dans le fichier `.gitmodules` pour être suivis
et utilisés dans le référentiel principal.

Cependant, elle ne récupère pas automatiquement les fichiers des sous-modules.
C'est pourquoi vous devez également exécuter la commande `git submodule update` pour obtenir les fichiers réels des
sous-modules.

```shell
git submodule update --recursive --remote
```

Cette commande met à jour tous les sous-modules du projet vers les derniers commits de leur branche par défaut dans le 
référentiel distant.

L'option `--recursive` est utilisée pour mettre à jour tous les sous-modules récursivement.
L'option `--remote` indique à Git de récupérer les derniers commits du référentiel distant plutôt que de rester sur les 
commits spécifiés dans le fichier `.gitmodules`

```shell
git submodule update
```

Cette commande met à jour tous les sous-modules du projet vers les commits spécifiés dans le fichier `.gitmodules`.

Il ne récupère pas automatiquement les derniers commits du référentiel distant.

```shell
git pull origin master
```
Cette commande met à jour le répertoire principal en récupérant les modifications de la branche `master` du référentiel 
distant du répertoire principal.

Si vous avez mis à jour vos sous-modules avec `git submodule update --recursive --remote` et que vous avez effectué des 
modifications dans le répertoire principal, vous pouvez envisager d'effectuer un `git pull origin master` pour récupérer 
les dernières modifications de la branche "master" du référentiel distant du répertoire principal

### Run
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


