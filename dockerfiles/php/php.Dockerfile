FROM docker.io/library/php:8.4-fpm
LABEL authors="valetainer"

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt update \
    && apt install git zip nodejs vim man -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require laravel/installer \
    && echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc \
    && sed -i "s/www-data/root/g" /usr/local/etc/php-fpm.d/www.conf

# /etc/php
# "$PHP_INI_DIR/php.ini"

WORKDIR /ValetainerProjects

ENTRYPOINT ["php-fpm", "--nodaemonize", "--allow-to-run-as-root"]
