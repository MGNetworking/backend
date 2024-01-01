#!/bin/bash
# NB git bash ne peut lancer ce fichier
# $1 represente siot : IP_DEV , IP_PRE, IP_PROD
attribut=$1

destination=".env"
echo "Lecture du script Get_IP_Config_Service.sh $attribut"

# Récupération de l'adresse IP de la machine
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
echo "Adresse IP : ${IP}"

# construction de l'URI
URI="http://${IP}:8089"
echo "Adresse URI : ${URI}"

# Vérification si le fichier de destination existe
if [ -f "$destination" ]; then

  # Extraction de la valeur actuelle de IP_DEV
  IP_DEV=$(grep -oP '^$attribut=\K.*' "$destination" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  echo "Valeur actuelle de $attribut : ${IP_DEV}"

else
  echo "Le fichier de destination $destination n'existe pas."
  exit 1 # erreur ou échec
fi

# Vérification des permissions d'écriture sur le fichier
if [ ! -w "$destination" ]; then
  echo "Impossible d'écrire dans le fichier $destination. Vérifiez les permissions."
  exit 1 # erreur ou échec
fi

awk -v str="$URI" -v att="$attribut" 'BEGIN {FS=OFS="="} $1==att {$2=str; copied=1} 1;
END {if (!copied) print "att="str}' "$destination" >temp_file && mv temp_file "$destination"

# Vérification de la copie
if grep -q "^$attribut=$URI$" "$destination"; then

  echo "La variable a été initialisée avec succès."
  exit 0 # sortie normale ou réussie
else

  echo "Erreur lors de la copie de la chaîne dans le fichier $destination."
  exit 1 # erreur ou échec
fi
