FROM docker.io/library/phpmyadmin:apache
LABEL authors="valetainer"

ARG PMA_ABSOLUTE_URI="phpmyadmin.test"

# /etc/phpmyadmin/config.user.inc.php
