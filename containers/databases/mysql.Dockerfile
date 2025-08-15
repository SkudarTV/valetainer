ARG MYSQL_VERSION=9.4.0

FROM docker.io/mysql:${MYSQL_VERSION}
LABEL authors="valetainer"

ENV MYSQL_ROOT_PASSWORD="root"

# /var/lib/mysql (data & logs)
