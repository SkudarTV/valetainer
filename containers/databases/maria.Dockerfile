ARG MARIADB_VERSION=11.8.2

FROM docker.io/mariadb:${MARIADB_VERSION}
LABEL authors="valetainer"

ENV MARIADB_ROOT_PASSWORD="root"

# /var/lib/mysql:Z (data & logs)
