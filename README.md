# API de Gestion des Articles avec Architecture Microservices

## Sommaire

* [Objectif](#objectif)
* [Fonctionnement](#fonctionnement-)
* [Gestion des dépendances avec Git Submodules](#gestion-des-dépendances-avec-git-submodules)
* [Setup](#setup)
    * [Workflow](#workflow)
* [Git Submodules](#git-submodules)
    * [Fonctionnement des Git Submodules](#fonctionnement-des-git-submodules)
        * [Initialisation des submodules](#initialisation-des-submodules)
        * [Mise à jour des submodule](#mise-à-jour-des-submodule-)
        * [Mise à jour des submodules avec des référentiels distants](#mise-à-jour-des-submodules-avec-des-référentiels-distants-)
        * [Mise à jour du projet principal](#mise-à-jour-du-projet-principal-)
        * [Ajout d'un sous-module au projet](#ajout-dun-sous-module-au-projet)

## Objectif

Ce projet consiste en une API développée avec Spring Boot, dédiée à la gestion des articles
de [mon site internet](https://ghoverblog.ovh/). À travers ce projet, j'ai eu l'opportunité d'explorer et de mettre en
pratique plusieurs technologies Spring,
notamment [Spring Cloud Gateway](https://github.com/spring-cloud/spring-cloud-gateway), [Spring Cloud Config](https://github.com/spring-cloud/spring-cloud-config),
et [Spring Cloud Netflix](https://github.com/spring-cloud/spring-cloud-netflix), afin de créer une architecture
microservices robuste et évolutive.
En outre, ce projet m'a permis de me familiariser avec Docker, en créant des images Docker de mes API et en les
déployant efficacement dans un environnement Docker Swarm.

## Fonctionnement

Information générale sur la création des services Spring Boot et de leur déploiement dans Docker Swarm

Nos services Spring Boot sont initialement développés et testés dans un environnement standard de développement. Une
fois validés, ces services sont conteneurisés en créant des images Docker correspondantes. Ces images sont ensuite
déployées dans un environnement Docker Swarm, où l'orchestration des conteneurs assure une gestion efficace de la mise à
l'échelle, de la distribution des charges et de la résilience des services.

## Gestion des dépendances avec Git Submodules

Ce projet utilise des Git submodules pour référencer d'autres projets. Les Git submodules permettent d'intégrer des
référentiels Git externes au sein d'un projet principal, tout en maintenant une séparation claire entre les codes
sources. Cela facilite la gestion des dépendances et permet de synchroniser les différentes parties du projet avec leurs
référentiels d'origine.

## Setup

### Workflow

Pour garantir un fonctionnement optimal, nos microservices suivent un ordre d'exécution spécifique dans Docker Swarm :

[Spring Cloud Config](https://github.com/spring-cloud/spring-cloud-config) : Ce service est démarré en premier pour
récupérer les propriétés de configuration stockées sur un
dépôt GitHub. Ces configurations sont ensuite partagées avec les autres
microservices.[info supplémentaire projet](https://spring.io/projects/spring-cloud-config)
et [info supplémentaire documentation](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/)

[Spring Cloud Netflix](https://github.com/spring-cloud/spring-cloud-netflix) : Après que les configurations sont en
place, le service Eureka Discovery permet à chaque microservice de s'enregistrer dans un registre central, facilitant
ainsi leur découverte mutuelle. [info supplémentaire](https://cloud.spring.io/spring-cloud-netflix/reference/html/)

[Spring Cloud Gateway](https://github.com/spring-cloud/spring-cloud-gateway) : Ce service, qui agit comme une passerelle
centrale, démarre ensuite. Il achemine les requêtes vers les API sous-jacentes en fonction des règles de routage
définies. [info supplémentaire](https://spring.io/projects/spring-cloud-gateway)

[Service Article](https://github.com/MGNetworking/ms-article/tree/eb5c7886dd15f81a3e16f75980299d62180ce8df) : Enfin, ce
microservice, responsable de la gestion des articles de l'application, s'enregistre auprès de Eureka et devient
accessible via le Spring Cloud Gateway. Il est également intégré avec [Keycloak](https://www.keycloak.org/) pour gérer
l'autorisation des utilisateurs
authentifiés. [Keycloak contrôle l'accès](https://www.keycloak.org/docs/latest/server_admin/) à certains points de
terminaison, assurant que seules les personnes autorisées peuvent effectuer des actions spécifiques sur les articles.

Cette architecture modulaire, soutenue par Docker Swarm, permet à nos applications de bénéficier d'une robustesse et
d'une flexibilité accrues tout en maintenant une continuité avec les environnements de développement.

## Git Submodules

### Fonctionnement des Git Submodules

Lors de la configuration initiale du projet, les submodules sont ajoutés en spécifiant l'URL du dépôt externe ainsi que
le chemin dans lequel il doit être intégré. Chaque submodule pointe vers un commit spécifique du dépôt référencé,
garantissant ainsi une cohérence entre les versions.

Pour cloner un projet qui contient des submodules, il est nécessaire de suivre ces étapes :

#### Initialisation des submodules

Une fois le projet cloné, vous devez initialiser les submodules avec la commande `git submodule init`. Cela configure
les submodules en fonction de la configuration du projet principal.

```shell
git submodule init
```

#### Mise à jour des submodule

Pour récupérer le contenu des submodules, vous utilisez la commande `git submodule
   update`. Cette commande clone les référentiels des submodules dans les chemins spécifiés et les synchronise avec les
versions définies.

```shell
git submodule update
```

#### Mise à jour des submodules avec des référentiels distants

Pour mettre à jour tous les submodules en suivant les branches distantes plutôt que les commits fixes, vous pouvez
utiliser la commande :

```shell
git submodule update --recursive --remote
```

Cette commande a deux options importantes :

L'option `--recursive`:  
Elle permet de mettre à jour les submodules de manière récursive, c'est-à-dire que si un submodule
contient lui-même des submodules, ceux-ci seront également mis à jour.

L'option `--remote` :  
Cette option force Git à récupérer les dernières modifications depuis les branches distantes spécifiées
dans chaque submodule, plutôt que de se contenter des versions fixées dans le projet principal.

Cette commande est particulièrement utile pour maintenir à jour les submodules qui sont en développement actif, en
s'assurant qu'ils suivent les branches distantes les plus récentes.

À chaque mise à jour du projet principal ou des submodules, il est essentiel de synchroniser les submodules pour
s'assurer que tous les éléments du projet fonctionnent correctement ensemble.

#### Mise à jour du projet principal

Une fois les submodules mis à jour, vous pouvez synchroniser le projet principal
avec son dépôt distant en utilisant la commande `git pull origin master`. Cette commande fusionne les dernières
modifications de la branche master du dépôt distant dans votre copie locale du projet. Cela garantit que votre
environnement de travail est à jour avec les derniers changements apportés au projet principal.

```shell
git pull origin master
```

#### Ajout d'un sous-module au projet

Pour ajouter un sous-module à votre projet Git, suivez ces étapes :

1. **Ajout du sous-module** :

Utilisez la commande suivante pour ajouter un sous-module à votre projet :

````shell
git submodule add <URL-du-dépôt> <chemin-du-sous-module>
````

- `<URL-du-dépôt>` : L'URL du dépôt Git que vous souhaitez ajouter comme sous-module.
- `<chemin-du-sous-module>` : Le chemin où vous voulez placer le sous-module dans votre projet. Ce chemin sera un
  répertoire contenant le code du sous-module.

Par exemple, pour ajouter un dépôt externe nommé `lib-example` dans un répertoire `libs/lib-example`, vous utiliseriez :

````shell
git submodule add https://github.com/example/lib-example.git libs/lib-example
````

2. **Validation de l'ajout** :  
   Après avoir ajouté le sous-module, vous devez valider les modifications apportées à votre projet principal avec la
   commande suivante :

````shell
git commit -m "Ajout du sous-module lib-example"
````

