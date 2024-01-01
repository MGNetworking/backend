#!/bin/bash

name_conteneur=("config-service" "eureka" "gateway-service")
name_images=("ms-configuration-service" "ms-eureka-service" "ms-gateway-service")
nom_reseau="blog-network"

delete_images() {

  # suppression de l'images conteneuriser
  docker rmi $1
  docker images -f "reference=$1"

  if [[ $? -eq 0 ]]; then
    echo "************************************"
    echo "L'images : $1:$VERSION_IMAGE a bien été supprimer "
  else
    echo "************************************"
    echo "L'images : $1:$VERSION_IMAGE n'a pas été supprimer "
  fi
}

delete_reseau() {

  # Vérifie si le conteneur est actif
  if docker ps -f "network=$1" -f "status=running" --format '{{.ID}}' | grep -q .; then
    echo "************************************"
    echo "Un conteneur est toujours actif sur le réseau bridge $1"
    echo "Le réseau $1 ne pourra pas être supprimer."
  else
    echo "************************************"
    echo "Les conteneurs ne sont plus actif sur le réseau bridge  $1"
    echo "Le réseau  $1 peut être supprimer "
    docker network rm $1
    docker network ls --filter "name=$1"

    if [[ $? -eq 0 ]]; then
      echo "************************************"
      echo "Le réseau a été supprimé avec succès."
    else
      echo "************************************"
      echo "Échec de la suppression du réseau  $1"
    fi
  fi

}

docker compose -f ./docker-compose-DEV.yml down

######### pour chaque conteneur
for contener in "${name_conteneur[@]}"; do

  # Vérifier si le conteneur n'est plus en cours d'exécution
  if [[ -z "$(docker ps -q -f 'status=exited' -f 'name='$contener)" ]]; then

    echo "************************************"
    echo "Le conteneur $contener n'est plus en cours d'exécution."

  else
    echo "************************************"
    echo "Le conteneur est toujours en cours d'exécution."
  fi

done

######### pour chaque images
for image in "${name_images[@]}"; do

  # Obtenir le tag (version) de l'image du conteneur
  tag=$(docker images --filter=reference=$image --format "{{.Tag}}")

  # par nom est son tag get le num de l'images
  if [[ $(docker images -q $image:$tag) != "" ]]; then
    delete_images $image:$tag
  else
    echo "************************************"
    echo "L'images : $image:$tag a déjà était supprimer "
  fi

done

###### supression du réseau
delete_reseau $nom_reseau

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
