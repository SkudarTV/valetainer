FROM docker.io/library/mariadb:11.8.2
LABEL authors="valetainer"

ENV MARIADB_ROOT_PASSWORD="root"

# /var/lib/mysql:Z (data & logs)
