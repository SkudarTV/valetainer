FROM docker.io/mysql:9.4.0
LABEL authors="valetainer"

ENV MYSQL_ROOT_PASSWORD="root"

# /var/lib/mysql (data & logs)
