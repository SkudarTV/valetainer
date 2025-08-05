ARG PHP_VERSION=8.4

FROM docker.io/library/php:${PHP_VERSION}-fpm
LABEL authors="valetainer"

ARG USER_UID

ENV USER_UID=${USER_UID}
ENV PHP_VERSION=${PHP_VERSION}

USER root
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt update \
    && apt install git zip nodejs vim man -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require laravel/installer \
    && echo "adduser --uid ${USER_UID} --shell /bin/bash --disabled-password --home /home/valetainer valetainer" \
    && adduser --uid ${USER_UID} --shell /bin/bash --disabled-password --home /home/valetainer valetainer \
    && sed -i "s/www-data/valetainer/g" /usr/local/etc/php-fpm.d/www.conf \
    && echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /home/valetainer/.bashrc

USER valetainer

# /etc/php
# "$PHP_INI_DIR/php.ini"

WORKDIR /ValetainerProjects

ENTRYPOINT ["php-fpm", "--nodaemonize"]
