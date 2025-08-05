FROM docker.io/library/nginx:1.29-alpine
LABEL authors="valetainer"

# COPY ./entrypoint.sh /scripts/entrypoint.sh
COPY ./conf.d/* /etc/nginx/conf.d/

#RUN cp /etc/nginx/nginx.conf /nginx.conf \
#    && chmod +x /scripts/*.sh

ENTRYPOINT ["nginx", "-g", "daemon off;"]

# /etc/nginx/nginx.conf
# /usr/share/nginx/html
# /var/log/nginx
