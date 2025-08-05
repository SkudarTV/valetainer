#!/bin/bash

PROJECT_DIR="$HOME/GolandProjects/valetainer"

if [ "$(id -u)" -eq 0 ];
then
  echo "/!\ You started this command with sudo ! Please re-run without."
  echo "Exiting..."
  exit
fi

USER_UID=$(id -u)
echo "Current user UID: $USER_UID"

CONTAINER_ENGINE=docker
if command -v podman > /dev/null 2>&1
then
  CONTAINER_ENGINE=podman
fi
echo "Using $CONTAINER_ENGINE as containerization engine"

# Remove containers
$CONTAINER_ENGINE container stop valetainer-mariadb && $CONTAINER_ENGINE container rm --volumes valetainer-mariadb
$CONTAINER_ENGINE container stop valetainer-php && $CONTAINER_ENGINE container rm --volumes valetainer-php
$CONTAINER_ENGINE container stop valetainer-pma && $CONTAINER_ENGINE container rm --volumes valetainer-pma
$CONTAINER_ENGINE container stop valetainer-nginx && $CONTAINER_ENGINE container rm --volumes valetainer-nginx
$CONTAINER_ENGINE container stop valetainer-dnsmasq && $CONTAINER_ENGINE container rm --volumes valetainer-dnsmasq

# Remove images
$CONTAINER_ENGINE image rm valetainer-mariadb:beta
$CONTAINER_ENGINE image rm valetainer-php:beta
$CONTAINER_ENGINE image rm valetainer-pma:beta
$CONTAINER_ENGINE image rm valetainer-nginx:beta
$CONTAINER_ENGINE image rm valetainer-dnsmasq:beta

# Network
$CONTAINER_ENGINE network rm valetainer
$CONTAINER_ENGINE network create valetainer \
  --driver=bridge

# Containers
cd $PROJECT_DIR/dockerfiles/databases
$CONTAINER_ENGINE image build -t "valetainer-mariadb:beta" -f maria.Dockerfile .
$CONTAINER_ENGINE run \
  --network valetainer \
  --restart unless-stopped \
  --name valetainer-mariadb \
  --hostname valetainer-mariadb \
  -d valetainer-mariadb:beta

cd $PROJECT_DIR/dockerfiles/php
$CONTAINER_ENGINE image build \
  -t "valetainer-php:beta" \
  --build-arg USER_UID=$USER_UID \
  -f php.Dockerfile .
$CONTAINER_ENGINE run \
  --network valetainer \
  --restart unless-stopped \
  --name valetainer-php \
  --hostname valetainer-php \
  --volume "$HOME/ValetainerProjects":/ValetainerProjects \
  -d valetainer-php:beta

cd $PROJECT_DIR/dockerfiles/phpmyadmin
$CONTAINER_ENGINE image build -t "valetainer-pma:beta" -f pma.Dockerfile .
$CONTAINER_ENGINE run \
  --network valetainer \
  --restart unless-stopped \
  --name valetainer-pma \
  --hostname valetainer-pma  \
  -d valetainer-pma:beta

sleep 2
cd $PROJECT_DIR/dockerfiles/nginx
$CONTAINER_ENGINE image build -t "valetainer-nginx:beta" -f nginx.Dockerfile .
$CONTAINER_ENGINE run \
  --network valetainer \
  --restart unless-stopped \
  --name valetainer-nginx \
  --hostname valetainer-nginx \
  -p 80:80 \
  -p 443:443 \
  --volume "$HOME/ValetainerProjects":/ValetainerProjects \
  -d valetainer-nginx:beta

sleep 2
cd $PROJECT_DIR/dockerfiles/dnsmasq
$CONTAINER_ENGINE image build -t "valetainer-dnsmasq:beta" -f dnsmasq.Dockerfile .

$CONTAINER_ENGINE run \
  --network valetainer \
  --restart unless-stopped \
  --name valetainer-dnsmasq \
  --hostname valetainer-dnsmasq \
  -p "53:53/tcp" \
  -p "53:53/udp" \
  -d valetainer-dnsmasq:beta

sleep 2
$CONTAINER_ENGINE ps -a
