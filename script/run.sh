#!/bin/bash

# Ce script attente un paramétre => $1
# Le contenur de ce paramétre :
# IP_DEV , IP_PRE , IP_PROD
# c'est variable sont contenu dans le fichier .env
# pour le script Get_IP_Config_Service.sh et aide a déterminer l'environnement
IP_ENV=$1
dockerCompose="docker-compose-DEV.yml"
name_conteneur=("config" "eureka" "gateway" "article")

# permet de déterminer l'environnement
run_env() {

  case $IP_ENV in
  "IP_DEV")
    echo "Mode DEV : run docker compose dev"
    dockerCompose="docker-compose-DEV.yml"
    ;;
  "IP_PRE")
    echo "Mode PRE PROD : run docker compose PRE PROD"
    dockerCompose="docker-compose-PRE.yml"
    ;;
  "IP_PROD")
    echo "Mode PROD : run docker compose PROD"
    dockerCompose="docker-compose-PROD.yml"
    ;;
  *)
    echo "Aucun environnement n'a été déclaré au lancement du script"
    exit 1
    ;;
  esac

}

run_conteneur() {

  if [[ $status == "running" ]]; then

    timeUTC=$(docker inspect --format='{{.State.StartedAt}}' $name_conteneur)
    conversion=$(date -d $timeUTC)
    echo "************************************"
    echo "Le conteneur $name_conteneur est en cour d'exécution depuis : $conversion"
    docker compose -f ./docker/docker-compose-DEV.yml logs -f

    # si a l'arrêt
  elif [[ $status == "exited" ]]; then
    echo "************************************"
    echo "Lancement du conteneur $name_conteneur"
    docker container start $name_conteneur
  fi

}

# Les scripts de version permettent d'initialisé les variable de version
# dans le fichier .env .
# La variable 1 cicle le projet
# La variable 2 permet de construire l'attribut version personnaliser
initialisation_scripts() {
  # initialisation des variables
  echo "************************************"
  echo "Lancement des scripts d'initialisations"

  # permet de déterminer l'environnement Dev / Pre / PROD
  run_env

  # Dans chaque projet (ms-xxxxx) sur chaque conteneur
  # la version du projet configuration
  script/version.sh ms-configuration config
  code_sortie_script_config=$1

  # la version du projet eureka
  script/version.sh ms-eureka eureka
  code_sortie_script_eureka=$1

  # la version du projet ms-gateway
  script/version.sh ms-gateway gateway
  code_sortie_script_gateway=$1

  # la version du projet ms-article
  script/version.sh ms-article article
  code_sortie_script_article=$1

  # L'adresse IP du micro service Configuration
  script/Get_IP_Config_Service.sh $IP_ENV
  code_sortie_script_Config=$1

  # L'adresse IP du micro service Eureka
  script/Get_IP_Eureka_Service.sh
  code_sortie_script_Eureka=$1

  case 1 in
  code_sortie_script_config)
    echo "Erreur est survenu dans le scripts de configuration "
    exit 1
    ;;
  code_sortie_script_eureka)
    echo "Erreur est survenu dans le scripts de eureka "
    exit 1 # erreur ou échec
    ;;
  code_sortie_script_gateway)
    echo "Erreur est survenu dans le scripts de gateway "
    exit 1 # erreur ou échec
    ;;
  code_sortie_script_article)
    echo "Erreur est survenu dans le scripts de article"
    exit 1 # erreur ou échec
    ;;
  code_sortie_script_Config)
    echo "Erreur est survenu dans le scripts de Configurarion"
    exit 1 # erreur ou échec
    ;;
  code_sortie_script_Eureka)
    echo "Erreur est survenu dans le scripts de Eureka"
    exit 1 # erreur ou échec
    ;;
  *)
    echo "Les scritps on initialisé avec succès ..."
    ;;
  esac

}

docker info >/dev/null 2>&1
DOCKER_STATUS=$?

# docker doit être en cours d'exécution
if [ $DOCKER_STATUS -eq 0 ]; then
  echo "************************************"
  echo "Docker est en cours d'exécution."

  # Permet de connaitre le status de tous les conteneures
  for conteneur in "${name_conteneur[@]}"; do

    status=$(docker inspect --format='{{.State.Status}}' $name_conteneur >/dev/null 2>&1)
    if [ -z "$status" ]; then
      echo "************************************"
      echo "le service $conteneur n'est pas en cours d'exécution"
    else
      echo "************************************"
      echo "le status du conteneur $conteneur est : $status"
    fi

  done # fin de la boucle

  initialisation_scripts

  for conteneur in "${name_conteneur[@]}"; do

    echo "************************************"
    echo "Build de l'images : $conteneur via le docker compose : $dockerCompose"
    docker compose -f ./$dockerCompose build --no-cache $conteneur
    docker compose -f ./$dockerCompose up -d $conteneur

    # Attendre que le conteneur de configuration soit prêt (vérifier la disponibilité)
    echo "Attente du démarrage du conteneur de $conteneur ..."
    while ! docker inspect -f '{{.State.Status}}' $conteneur >/dev/null 2>&1; do
      sleep 1
    done

  done

  echo "************************************"
  # Afficher les journaux (logs)
  docker compose -f ./$dockerCompose logs -f

else

  echo "************************************"
  echo "Docker n'est pas en cours d'exécution."
fi
