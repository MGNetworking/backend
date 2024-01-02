#!/bin/bash

destination=".env"
variable_cible="version_$2"

# Vérifier si xmlstarlet est installé
#if ! command -v xmlstarlet &>/dev/null; then
#  echo "Installation de xmlstarlet..."
#  sudo apt-get update && apt-get install -y xmlstarlet
#fi

echo "************************************"
echo "Recherche de la version du projet $2"

# Récupérer la version du projet à partir du fichier pom.xml
PROJECT_VERSION=$(xmlstarlet sel -N x="http://maven.apache.org/POM/4.0.0" -t -v "//x:project/x:version" "$1/pom.xml")

if [ -z $PROJECT_VERSION ]; then

  echo "------------"
  echo "La version du projet $2 n'a pas pu être récupérer"
  echo "************************************"
  exit 1 # renvoy false

else

  echo "------------"
  echo "Projet $2 | version $PROJECT_VERSION"

  # Vérification si le fichier de destination existe
  if [ -f "$destination" ]; then
    # Extraction de la valeur actuelle de IP_DEV
    version=$(grep -oP '^$variable_cible=\K.*' "$destination" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "------------"
    echo "Valeur actuelle de $variable_cible : ${version}"
  else
    echo "------------"
    echo "Le fichier de destination $destination n'existe pas."
    exit 1 # renvoy false
  fi

  # Vérification des permissions d'écriture sur le fichier
  if [ ! -w "$destination" ]; then
    echo "------------"
    echo "Impossible d'écrire dans le fichier $destination. Vérifiez les permissions."
    exit 1 # erreur ou échec
  fi

  awk -v str="$PROJECT_VERSION" -v variable_cible="$variable_cible" 'BEGIN {FS=OFS="="} $1==variable_cible && NF==2 {$2=str; copied=1} 1;
END {if (!copied) print variable_cible"="str}' "$destination" >temp_file && mv temp_file "$destination"

  # Vérification de la copie
  if grep -q "^$variable_cible=$PROJECT_VERSION$" "$destination"; then
    echo "------------"
    echo "Le projet $2 à initialisée sa version $PROJECT_VERSION"
    echo "************************************"
    exit 0 # sortie normale ou réussie
  else
    echo "------------"
    echo "Erreur lors de la copie de la chaîne dans le fichier $destination"
    echo "************************************"
    exit 1 # erreur ou échec
  fi

fi
