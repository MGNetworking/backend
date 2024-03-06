#!/bin/bash

name_conteneur=("ms-configuration" "ms-eureka" "ms-gateway" "ms-article")
name_images=("ms-configuration-service" "ms-eureka-service" "ms-gateway-service" "ms-article-service")

delete_images() {

  # suppression de l'images conteneuriser
  docker rmi $1
  docker images -f "reference=$1"

  if [[ $? -eq 0 ]]; then
    echo "L'images : $1:$VERSION_IMAGE a bien été supprimer "
  else
    echo "L'images : $1:$VERSION_IMAGE n'a pas été supprimer "
  fi
  echo "************************************"
}

docker compose -f ./docker-compose-DEV.yml down

######### pour chaque conteneur
for contener in "${name_conteneur[@]}"; do

  # Vérifier si le conteneur n'est plus en cours d'exécution
  if [[ -z "$(docker ps -q --filter 'name='$contener)" ]]; then

    echo "************************************"
    echo "Le conteneur $contener n'est plus en cours d'exécution."

  else
    echo "************************************"
    echo "Le conteneur est toujours en cours d'exécution."
  fi

done
echo "************************************"

######### pour chaque images
for image in "${name_images[@]}"; do

  # Obtenir le tag (version) de l'image du conteneur
  tag=$(docker images --filter=reference=$image --format "{{.Tag}}")

  # par nom est son tag get le num de l'images
  if [[ $(docker images -q $image:$tag) != "" ]]; then
    delete_images $image:$tag
  else
    echo "L'images : $image:$tag a déjà était supprimer "
    echo "************************************"
  fi

done

echo "************************************"
echo "Suppression des images Docker sans étiquette "
docker image prune -f -a

# affichage
echo "************************************"
echo "Liste des processus en cours d'exécution "
docker ps -a

echo "************************************"
echo "Liste des images déployées "
docker images

echo "************************************"
echo "List des réseaux "
docker network ls
