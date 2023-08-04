# YOC: Your Own Cloud

<img src="" width="200px">

## Description
This installation Wizard will install the followings services depending of your choices using docker and docker compose
- [Traefik](https://traefik.io/traefik)
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
- [Seafile](https://www.seafile.com/)
- [Nextcloud](https://nextcloud.com/)
- [wg-easy](https://github.com/wg-easy/wg-easy)
- [AddGuard Home](https://adguard.com/)
- [Immich](https://immich.app/)

## OS Supported
### Debian
- Debian Bookworm 12 (Stable)
- Debian Bullseye 11 (Oldstable)

### Ubuntu
- Ubuntu Lunar 23.04
- Ubuntu Kinetic 22.10
- Ubuntu Jammy 22.04 (LTS)
- Ubuntu Focal 20.04 (LTS)

## Features
- Install docker and docker compose if not installed
- Install services using docker and docker compose
- Configure the reverse proxy (Traefik) using your own domain or a local domain (yoc.local)
    - If you install Traefik you will be asked if you want to use Cloudflare to perform a DNS Challenge for SSL Certificate with Let's Encrypt using your own domain, also you will be asked if you want to create DNS Record on Cloudflare for the services selected using your Cloudflare API Key.
    - If not, a local domain **yoc.local** will be used.
- Create random password for the services selected.
- If AddGuard Home is installed, DNS entries will be created for your services.
- If AddGuard Home and Wireguard are installed, Wireguard will use Addguard Home as DNS server.
- yoc cli tools to manage your services

## Dependencies
- git
- docker and docker compose
- whiptail

## Before starting the installation
- Install git
```
(sudo) apt install git
```
- Having your domain name and Cloudfalre API Key for the domain you want to use.

## Starting the installation
```
git clone https://github.com/2nistechworld/yoc.git
cd yoc
chmod +x install.sh
(sudo) ./install.sh
```
And follow the instructions.

## YOC CLI Tool
```
# yoc
Usage: yoc --usage|restart|stop|start|update|status
--usage     display usage message
restart    restarts all services
stop       stops all services
start      starts services
update     update the containers and restart the services
status     display the status of the containers
```

## How to get your Cloudflare API Key
To get you API token go to https://dash.cloudflare.com/profile/api-tokens

- Click Create Token
- choose Edit zone DNS template
- Configure like this with your own domain

<img src="" style=" width:50px ; eight:50px " >

- Continue to summary and save your API token