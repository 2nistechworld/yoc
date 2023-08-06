# YOC: Your Own Cloud
<img src="/images/install.gif" width="500px">

## Description
This installation Wizard will install the followings services depending of your choices using docker and docker compose
- [Traefik](https://traefik.io/traefik): Reverse proxy manager, to make sure, you are not exposing your server to the public.
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden): Password manager, to store passwords, one time passwords for two factor authentication and secret documents and notes.
- [Seafile](https://www.seafile.com/): Files storage, sync and sharing solution. A good self hosted equivalent of DropBox / OneDrive.
- [Nextcloud](https://nextcloud.com/): All in one Cloud solution, for file storing and sharing, document collaboration, calendar and contact synchronisation, and much more.
- [wg-easy](https://github.com/wg-easy/wg-easy): Wireguard VPN, to make sure, only certain people can access your services via a secure VPN.
- [AdGuard Home](https://adguard.com/): Server side ad blocking, to remove ads and other malicious content before it reaches your computer. Can also act as a DNS/DHCP server.
- [Immich](https://immich.app/): Photos library, to make photo collection easy, can include automatic face recognition, tagging, and much more, great Google/Apple photo alternative.

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
    - If you install Traefik you will be asked if you want to use Cloudflare to perform a DNS Challenge for SSL Certificate with Let's Encrypt using your own domain, also you will be asked if you want to create DNS Record on Cloudflare for the services selected using your [Cloudflare API Key](https://github.com/2nistechworld/yoc#how-to-get-your-cloudflare-api-key).
    - If not, a local domain **yoc.local** will be used.
- Create random password for the services selected.
- If AdGuard Home is installed, DNS entries will be created for your services.
- If AdGuard Home and Wireguard are installed, Wireguard will use Addguard Home as DNS server.
- [YOC CLI](https://github.com/2nistechworld/yoc#yoc-cli-tool) tools to manage your services 
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
<img src="/images/yoc.gif" width="500px" >

## How to get your Cloudflare API Key
To get you API token go to https://dash.cloudflare.com/profile/api-tokens

- Click Create Token
- choose Edit zone DNS template
- Configure like this with your own domain
<img src="/images/get-cf-api-key.png" style=" width:50% ; align:center " >

- Continue to summary and save your API token

## Files structure
```
yoc/
├── compose_files
│   ├── adguardhome.yaml
│   ├── nextcloud.yaml
│   ├── seafile.yaml
│   ├── traefik.yaml
│   ├── vaultwarden.yaml
│   └── wg-easy.yaml
├── containers_data
│   ├── adguardhome
│   ├── nextcloud
│   ├── seafile
│   ├── traefik
│   ├── vaultwarden
│   └── wireguard
└── infos.txt
```
## Thanks
This project has been inspired by [YAMS](https://yams.media/)

Also please support the developpers of:
- [Traefik](https://traefik.io/traefik)
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
- [Seafile](https://www.seafile.com/)
- [Nextcloud](https://nextcloud.com/)
- [wg-easy](https://github.com/wg-easy/wg-easy)
- [AdGuard Home](https://adguard.com/)
- [Immich](https://immich.app/)
