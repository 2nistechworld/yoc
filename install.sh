#!/bin/bash
source ./functions.sh

#Pre-Check
check_os_installed
check_whiptail_is_installed

whiptail --title "YOC Installation" --msgbox "Welcome to YOC (Your Own Cloud)\nPlease follow the instructions to install the services." 8 78

###Start functions
check_if_docker_installed
check_if_docker_working

##What do you want to install
whiptail --title="YOC Installation" --checklist --separate-output "What do you want to install? " 20 78 15 \
"Traefik" "Reverse proxy with automatic SSL configuration" on \
"Vaultwarden" "Password Manager" off \
"Seafile" "DropBox Like" off \
"Nextcloud" "DropBox Like with more functionnaliies." off \
"Immich" "Self-hosted photo and video backup solution" off \
"Wg-Easy" "VPN Server using Wireguard" off \
"AdguardHome" "AD Blocker DNS/DHCP Server" off 2>results
whiptail_cancel_escape

while read choice
  do
    case $choice in
       Traefik)
        TRAEFIK=1      
        ;;
      Vaultwarden)
        VAULTWARDEN=1      
        ;;
      Seafile)
        SEAFILE=1
        ;;
      Nextcloud)
        NEXTCLOUD=1
        ;;
      Wg-Easy)
        WG_EASY=1
        ;;
      AdguardHome)
        ADGUARDHOME=1
        ;;
      Immich)
        IMMICH=1
        ;;
      *)
      ;;
    esac
  done < results
  
##Questions
YOC_FOLDER=$(whiptail --title="YOC Installation" --inputbox "Where do you want to install YOC? default [/opt/yoc] " 8 78 3>&1 1>&2 2>&3)
if [[ $? == 0 ]] ; then
  if [ -z "$YOC_FOLDER" ]; then
    YOC_FOLDER=/opt/yoc
  fi
else
    exit 0
fi

EMAIL_ADDRESS=$(whiptail --title="YOC Installation" --inputbox "What's your email address?" 8 78 3>&1 1>&2 2>&3)
whiptail_cancel_escape

SERVER_IP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1
)

#If Vaultwarden selected ask if we want to install Traefik for SSL
if [[ $VAULTWARDEN == 1 ]] && [[ $TRAEFIK != 1 ]]
then
  whiptail --title "YOC Installation" --yesno "Vaultwarden need to use HTTPS, do you want to install Traefik?." 8 78
  if [[ $? -eq 0 ]]; then
    TRAEFIK=1  
  elif [[ $? -eq 1 ]]; then 
    whiptail --title "YOC Installation" --msgbox "OK, you can manage SSL and reverse proxy by yourself." 8 78
  elif [[ $? -eq 255 ]]; then 
    whiptail --title "YOC Installation" --msgbox "User pressed ESC. Exiting the script" 8 78 
  fi
fi

#If Traefik selected ask if we want to use Cloudflare DNS for SSL
if [[ $TRAEFIK == 1 ]]
then
  if [[ $NEXTCLOUD == 1 ]] || [[ $VAULTWARDEN == 1 ]] || [[ $SEAFILE == 1 ]] || [[ $IMMICH == 1 ]]
  then
    whiptail --title "YOC Installation" --yesno "Do you want to use Cloudflare DNS to confgure SSL for Traefik?." 8 78
        if [[ $? -eq 0 ]]; then
          configure_cloudflare
        elif [[ $? -eq 1 ]]; then 
          whiptail --title "YOC Installation" --msgbox "OK, Traefik will use self signed certificate and use the domain yoc.local." 8 78
          DOMAIN_NAME=yoc.local
          create_domains_list
          install_wg_easy_or_adguardghome          
        elif [[ $? -eq 255 ]]; then 
          whiptail --title "YOC Installation" --msgbox "User pressed ESC. Exiting the script" 8 78 
        fi
  fi
fi

#Creating docker-compose.yaml file
CONTAINERS_DATA=$YOC_FOLDER/containers_data
COMPOSE_FILES_FOLDER=$YOC_FOLDER/compose_files
ENV_FILE=$COMPOSE_FILES_FOLDER/.env
mkdir -p $CONTAINERS_DATA
mkdir -p $COMPOSE_FILES_FOLDER

cp compose_files/.env $ENV_FILE

#General
sed -i "s;<EMAIL_ADDRESS>;$EMAIL_ADDRESS;g" $ENV_FILE
sed -i "s;<CONTAINERS_DATA>;$CONTAINERS_DATA;g" $ENV_FILE
sed -i "s;<DOMAIN_NAME>;$DOMAIN_NAME;g" $ENV_FILE

if [[ $TRAEFIK == 1 ]]; then
  cp compose_files/traefik.yaml $COMPOSE_FILES_FOLDER
  sed -i "s;<CLOUDFLARE_API_KEY>;$CLOUDFLARE_API_KEY;g" $ENV_FILE
fi

if [[ $VAULTWARDEN == 1 ]]; then
  cp compose_files/vaultwarden.yaml $COMPOSE_FILES_FOLDER
fi

if [[ $SEAFILE == 1 ]]; then
  SEAFILE_MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  SEAFILE_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  cp compose_files/seafile.yaml $COMPOSE_FILES_FOLDER
  sed -i "s;<SEAFILE_MYSQL_PASSWORD>;$SEAFILE_MYSQL_PASSWORD;g" $ENV_FILE
  sed -i "s;<SEAFILE_ADMIN_PASSWORD>;$SEAFILE_ADMIN_PASSWORD;g" $ENV_FILE
fi

if [[ $NEXTCLOUD == 1 ]]; then
  NEXTCLOUD_ROOT_MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  NEXTCLOUD_MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  cp compose_files/nextcloud.yaml $COMPOSE_FILES_FOLDER
  sed -i "s;<NEXTCLOUD_ROOT_MYSQL_PASSWORD>;$NEXTCLOUD_ROOT_MYSQL_PASSWORD;g" $ENV_FILE
  sed -i "s;<NEXTCLOUD_MYSQL_PASSWORD>;$NEXTCLOUD_MYSQL_PASSWORD;g" $ENV_FILE
fi

if [[ $IMMICH == 1 ]]; then
  IMMICH_TYPESENSE_API_KEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  IMMICH_DB_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  cp compose_files/immich.yaml $COMPOSE_FILES_FOLDER
  sed -i "s;<IMMICH_DB_PASSWORD>;$IMMICH_DB_PASSWORD;g" $ENV_FILE
  sed -i "s;<IMMICH_TYPESENSE_API_KEY>;$IMMICH_TYPESENSE_API_KEY;g" $ENV_FILE
fi   

if [[ $WG_EASY == 1 ]]; then
  cp compose_files/wg-easy.yaml $COMPOSE_FILES_FOLDER
  WG_EASY_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  sed -i "s;<WG_EASY_PASSWORD>;$WG_EASY_PASSWORD;g" $ENV_FILE
fi

if [[ $ADGUARDHOME == 1 ]]; then
  cp compose_files/adguardhome.yaml $COMPOSE_FILES_FOLDER
  mkdir -p $CONTAINERS_DATA/adguardhome/conf/
  cp config_files/AdGuardHome.yaml $CONTAINERS_DATA/adguardhome/conf/AdGuardHome.yaml
  ADGUARDHOME_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 35 ; echo '')
  docker pull httpd:2.4
  ADGUARDHOME_PASSWORD_HASH=$(docker run httpd:2.4 htpasswd -B -n -b $EMAIL_ADDRESS $ADGUARDHOME_PASSWORD | cut -d ":" -f2)
  sed -i "s;<ADGUARDHOME_PASSWORD_HASH>;$ADGUARDHOME_PASSWORD_HASH;g" $CONTAINERS_DATA/adguardhome/conf/AdGuardHome.yaml
  ##Create DNS rewrites based on the DNS list
  while read line;
    do
      echo "    - domain: '$line'" >> adguard_rewrites
      echo "      answer: $SERVER_IP">> adguard_rewrites
    done < dns.list
  sed -ie '/rewrites/radguard_rewrites' $CONTAINERS_DATA/adguardhome/conf/AdGuardHome.yaml
  sed -i "s;<EMAIL_ADDRESS>;$EMAIL_ADDRESS;g" $CONTAINERS_DATA/adguardhome/conf/AdGuardHome.yaml
fi

#Wg-Easy && AdguardHome
if [[ $WG_EASY == 1 ]] && [[ $ADGUARDHOME == 1 ]]
  then
  sed -i "s;<WG_DEFAULT_DNS>;172.8.0.53;g" $ENV_FILE
  else
  sed -i "s;<WG_DEFAULT_DNS>;1.1.1.1;g" $ENV_FILE
fi


##Informations to display at the end
INFOS_TXT=$YOC_FOLDER/infos.txt
touch $INFOS_TXT

if [[ $TRAEFIK == 1 ]]; then
  echo "Traefik:" >> $INFOS_TXT
  echo "URL: http://$SERVER_IP:8080" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

if [[ $VAULTWARDEN == 1 ]]; then
  echo "Vaultwarden:" >> $INFOS_TXT
  echo "URL: https://vaultwarden.$DOMAIN_NAME" >> $INFOS_TXT
  echo "Create you frist account" >> $INFOS_TXT
  echo "Set the value to SIGNUPS_ALLOWED=false in $COMPOSE_FILES_FOLDER/vaultwarden.yaml" >> $INFOS_TXT
  echo "To avoid unwanted users to register" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

if [[ $NEXTCLOUD == 1 ]]; then
  echo "Nextcloud:" >> $INFOS_TXT
  echo "URL: https://nextcloud.$DOMAIN_NAME or http://$SERVER_IP:8082" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

if [[ $SEAFILE == 1 ]]; then
  echo "Seafile:" >> $INFOS_TXT
  echo "URL: https://seafile.$DOMAIN_NAME or http://$SERVER_IP:8081" >> $INFOS_TXT
  echo "Seafile Admin Username: $EMAIL_ADDRESS" >> $INFOS_TXT
  echo "Seafile Admin Password: $SEAFILE_ADMIN_PASSWORD" >> $INFOS_TXT
  echo "Do not forget to reset the Admin password and Activate 2FA" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

if [[ $IMMICH == 1 ]]; then
  echo "Immich:" >> $INFOS_TXT
  echo "URL: https://immich.$DOMAIN_NAME or http://$SERVER_IP:2283" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi
  
if [[ $WG_EASY == 1 ]]; then
  echo "WireGuard VPN" >> $INFOS_TXT
  echo "You can access wg-easy UI using http://$SERVER_IP:51821" >> $INFOS_TXT
  echo "Wg-Easy password: $WG_EASY_PASSWORD" >> $INFOS_TXT 
  echo "Open the port 51820/UDP on your firewall to $SERVERIP to access remotely" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

if [[ $ADGUARDHOME == 1 ]]; then
  echo "AdGuard Home" >> $INFOS_TXT
  echo "URL: http://$SERVER_IP:80" >> $INFOS_TXT
  echo "AdGuard Home Username: $EMAIL_ADDRESS" >> $INFOS_TXT
  echo "AdGuard Home Password: $ADGUARDHOME_PASSWORD" >> $INFOS_TXT
  echo "You can use $SERVER_IP as DNS Server to resolve localy $DOMAIN_NAME" >> $INFOS_TXT
  echo " " >> $INFOS_TXT
fi

INFOS=$(cat $INFOS_TXT)

##Create docker network
CHECK_YOC_NETWORK=$(docker network list | grep yoc_network)
if [ -z "$CHECK_YOC_NETWORK" ]
  then
      docker network create --driver=bridge --subnet=172.19.0.0/16 --gateway=172.19.0.1 yoc_network
fi

#Installation YOC CLI
YOC_CLI=/usr/local/bin/yoc
cp yoc $YOC_CLI
sed -i "s;<YOC_FOLDER>;$YOC_FOLDER;g" $YOC_CLI
chmod +x $YOC_CLI

whiptail --title "YOC Installation" --msgbox "Configuration completed, the services will now start." 8 78
#Start everything
yoc start

whiptail --title "YOC Installation" --msgbox --scrolltext "$INFOS" 30 78
whiptail --title "YOC Installation" --msgbox " All the informations are saved into $INFOS_TXT" 20 78

#cleanup
DNSLIST=dns.list
if [ -f "$DNSLIST" ]; then
    rm $DNSLIST
fi
ADGUARD_FILE=adguard_rewrites
if [ -f "$ADGUARD_FILE" ]; then
    rm $ADGUARD_FILE
fi
rm results