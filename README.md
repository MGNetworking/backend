## Table of contents

* [General info](#general-info)
* [Setup](#setup)
    * [Workflow](#workflow)
    * [Initialisation du projet](#initialisation-du-projet)
    * [Before Run](#Before-Run)
    * [Run](#run)

## General info

Ce projet est le regroupement plusieurs sous projet Spring boot dans la forme de sous module. Ces projets sont des
micro-services pour la gestion du blog possèdent le nom de domain : **ghoverblog**

## Setup

## Workflow

Ce projet est composé de sous module interdépendant. Ces modules doivent respecter un ordre de lancement.

De plus, tous ces services fonctionnent dans un réseau docker nommé `keycloak_postgre` son alias `sso_bd`.
La création de ce réseau est gérée par le
projet [docker-keycloak-postgres](https://github.com/MGNetworking/docker-keycloak-postgres).

Aussi le micro-service `article` fonction conjointement avec `Keycloak` pour la partie authentification des
utilisateurs. En fait, les utilisateurs s'authentifient en amont (via la partie front-end du projet) puis une requête
est effectué de manière transparente pour l'utilisateur du micro-service dans le but verifier ces droits d'accès.

Avoir lancé au préalable les projet `docker-keycloak-postgres` puis les services dans l'ordre suivant :

* `config` Ce service permet d'obtenir les configurations pour chaque sous module


* `eureka ` Ce service permet de référencer les services en cours execution. Il est utilisé par le service gateway.
  Après le lancement de chaque service, ils s'inscrivent à eureka.


* `gateway` Ce service est la passerelle vers les services sous-jacents. Il permet de distribuer
  les requêtes vers les microservice inscrit par le service `eureka`


* `article` Ce service permet la gestion des articles du site.

Dans le but d'automatiser les processus de lancement, le `docker compose` supervise l'ordonnancement du projet en
utilisant le mot clef `depends_on`.

Aussi un script `run.sh` est prévu à cet effet. Pour avoir plus d'information sur savoir comment lancer ce script,
veuiller vous rendre dans la partie [Before-Run](#before-run).

NB : Le projet `docker-keycloak-postgres` doit impérativement être en cours d'exécution avant le lancement du docker
compose

### Initialisation du projet

Ce projet ne contient directement tous les dossiers comment dans un projet ordinaire. Il est géré avec les sous module
git, ce qui veut dire que vous devez initialiser puis les metres a jours dans le context du projet principal.

Pour cela, vous suivre les commande suivante :

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
Elle ne récupère pas automatiquement les derniers commits du référentiel distant.

```shell
git pull origin master
```

Cette commande met à jour le répertoire principal en récupérant les modifications de la branche `master` du référentiel
distant du répertoire principal.

Si vous avez mis à jour vos sous-modules avec `git submodule update --recursive --remote` et que vous avez effectué des
modifications dans le répertoire principal. Vous pouvez envisager d'effectuer un `git pull origin master` pour récupérer
les dernières modifications de la branche "master" du référentiel distant du répertoire principal.

### Before-Run

Le script `run.sh` est le script de lancement du projet, il lance d'autre script en cascade permettent la bonne
exécution du projet. Certain de ces scripts sont exécutables avec le `Shell git`, Mais pas tous.

Par exemple le script `version.sh`, il a besoin d'installer l'utilitaire `xmlstarlet` qui fonctionne sur
uniquement dans les environnements `linux`.

### Run

Les scripts exécutés par `run.sh` pour fonctionner ont besoin des tools suivant :

```shell
sudo apt install xmlstarlet
sudo apt install net-tools
```

`xmlstarlet`est une boîte à outils en ligne de commande qui permet de traiter des documents XML de manière
variée. Il peut être utilisé pour extraire des informations, manipuler et éditer des fichiers XML.
Il est utilisé dans le script `version.sh`

`net-tools` est un ensemble d'outils en ligne de commande qui fournit diverses informations réseau. Cela inclut des
commandes comme `ifconfig` pour configurer les interfaces réseau, netstat pour afficher les connexions réseau, et
d'autres
outils utiles. Il est utilisé dans le script `Get_IP_Config_Service.sh`

Rendre tous les scripts exécutables :

```shell
chmod -R +x script/
```

Pour lancer le docker compose principale, vous devez utiliser le script `run.sh` Ce script contient le processus complet
permettent d'initialiser les variables contenus dans le fichier `.env` situé à la racine du projet.

Il permet aussi de déterminer l'IP local de la machine dans le but de localiser les micro-services de configuration et
de registre (eureka).

Il permet aussi de récupérer les versions des micro services pour la création des images

Comment lancer ce script, voici un exemple avec l'environnement de développement :

```shell
./script/run.sh IP_DEV
```

Le paramètre `IP_DEV` correspond à l'environnement de développement utilisé dans le script. Elle permet aussi,
de faire référence à une variable contenue dans le fichier `.env` qui participe l'exécution du script.

`IP_DEV` : pour l'environnement de développement  
`IP_PRE` : pour l'environnement de pré-production  
`IP_PROD` : pour l'environnement de production

Pour l'arrêt complet des services lancer par le docker compose principal. Ce script supprimera les conteneurs est leur
image respective.

```shell
./script/down.sh 
```

Pour arrêter un service `de manière distinct` qui a été lancé avec le `docker compose` principale

```shell
docker compose -f docker-compose-DEV.yml stop article
```

Puis pour le supprimer

```shell
docker compose -f docker-compose-DEV.yml rm -s -f article
```

`les options`   
Dans cette commande, `l'option -s` est utilisée pour arrêter le service avant de le supprimer, et `l'option -f` force la
suppression du service même s'il est en cours d'exécution.

Si vous avez arrêté le service `article` et que vous souhaitez le redémarrer en reconstruisant l'image, vous pouvez
utiliser la commande docker compose up avec la sous commande `build` pour forcer la reconstruction de l'image.
Voici comment vous pouvez le faire :

```shell
# build 
docker compose -f docker-compose-DEV.yml build --no-cache article

# puis run
docker compose -f docker-compose-DEV.yml up -d article
```

`les options`
l'option `--no-cache` dans la commande de construction (docker compose build) est utilisée pour forcer la reconstruction
sans utiliser le cache des couches d'image. Cela signifie que toutes les étapes de construction seront exécutées à
partir de zéro, même si les étapes précédentes sont en cache.

Dans cet exemple, je stoppe et supprime le service article, puis, je build l'image et créer le conteneur en
utilisant le docker compose principal, qui respecter l'ordre des dépendances entre conteneur 