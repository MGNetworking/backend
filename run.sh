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
