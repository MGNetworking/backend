#!/bin/bash

dockerComposeSwarmSousModule="docker-compose-swarm.yml"
dockerComposeBuild="docker-compose-DEV-swarm.yml"
name_conteneur=( "ms-eureka" "ms-gateway" "ms-article")

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

    echo "************************************"
    echo "Création de l'images : ms-configuration depuis $dockerComposeBuild"
    docker compose -f ./$dockerComposeBuild build --no-cache ms-configuration

    echo "************************************"
    echo "Création de la stack du service : $service depuis ${PWD}/ms-configuration/$dockerComposeSwarmSousModule"
    docker stack deploy -c ${PWD}/ms-configuration/$dockerComposeSwarmSousModule stack

    echo "************************************"
    echo "Vérification que le conteneur ms-configuration Soit UP"

    etat="true"

    while [ "$etat" = "true" ] ; do

        status="UNKNOWN"
        echo  "status du service ms-configuration : $status"
        status=$(curl -s -m 30 http://192.168.1.68:8089/actuator/health | jq -r '.status' )

        if  [ "$status" = "UP" ]; then
          echo  "le service  ms-configuration est : $status"
          etat="false"

        elif [ "$status" = "DOWN" ]; then
          echo  "status du service $service : $status"
          exit 1 # exit du script
        fi

      sleep 5
    done


  for conteneur in "${name_conteneur[@]}"; do

    echo "************************************"
    echo "Création de l'images : $conteneur depuis $dockerComposeBuild"
    docker compose -f ./$dockerComposeBuild build --no-cache $conteneur

  done

  for service in "${name_conteneur[@]}"; do

      echo "************************************"
      echo "Création de la stack du service : $service depuis ${PWD}/$service/$dockerComposeSwarmSousModule"
      docker stack deploy -c ${PWD}/$service/$dockerComposeSwarmSousModule stack

  done

  echo "************************************"
  echo "Fin du script "

else

  echo "************************************"
  echo "Docker n'est pas en cours d'exécution."
fi
