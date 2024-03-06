#!/bin/bash

dockerCompose="docker-compose-DEV.yml"
name_conteneur=("ms-configuration" "ms-eureka" "ms-gateway" "ms-article")

docker info >/dev/null 2>&1
DOCKER_STATUS=$?

# docker doit être en cours d'exécution
if [ $DOCKER_STATUS -eq 0 ]; then
  echo "************************************"
  echo "Docker est en cours d'exécution."

  # Permet de connaitre le status de tous les conteneurs
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


  for conteneur in "${name_conteneur[@]}"; do

    echo "************************************"
    echo "Création de l'images : $conteneur "
    #docker compose -f ./$dockerCompose --env-file ${PWD}/$conteneur/.env build --no-cache $conteneur
    docker compose -f ./$dockerCompose build --no-cache $conteneur

    echo "************************************"
    echo "Création du conteneur $conteneur"
    #docker compose -f ./$dockerCompose --env-file ${PWD}/$conteneur/.env up -d $conteneur
    docker compose -f ./$dockerCompose up -d $conteneur

    echo "************************************"
    echo "Attente du démarrage du conteneur de $conteneur ..."
    while ! docker inspect -f '{{.State.Status}}' $conteneur >/dev/null 2>&1; do
      sleep 1
    done

    echo "************************************"
    echo "Le conteneur de $conteneur est prêt."

  done

  echo "************************************"
  # Afficher les journaux (logs)
  docker compose -f ./$dockerCompose logs -f

else

  echo "************************************"
  echo "Docker n'est pas en cours d'exécution."
fi
