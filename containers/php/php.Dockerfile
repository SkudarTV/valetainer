ARG PHP_VERSION=8.4

FROM docker.io/php:${PHP_VERSION}-fpm
LABEL authors="valetainer"

ARG USER_UID
ENV USER_UID=${USER_UID}

COPY ./composer-installer.sh /composer-installer.sh

USER root
RUN adduser --uid ${USER_UID} --shell /bin/bash --disabled-password --home /home/valetainer --gecos "" valetainer \
    && usermod -aG sudo valetainer \
    && sed -i "s/www-data/valetainer/g" /usr/local/etc/php-fpm.d/www.conf \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt update \
    && apt install git zip nodejs vim man dnsutils -y \
    && sh /composer-installer.sh \
    && mv composer.phar /usr/local/bin/composer \
    && chown valetainer:valetainer /usr/local/bin/composer \
    && echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /home/valetainer/.bashrc

USER valetainer
RUN composer global require laravel/installer

# /etc/php
# "$PHP_INI_DIR/php.ini"

WORKDIR /ValetainerProjects

ENTRYPOINT ["php-fpm", "--nodaemonize"]
