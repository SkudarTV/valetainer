#FROM docker.io/nginx:1.29-alpine
FROM docker.io/nginxinc/nginx-unprivileged:1.29-alpine
LABEL authors="valetainer"

# COPY ./entrypoint.sh /scripts/entrypoint.sh
COPY ./proxy.conf.d/proxy.*.conf /etc/nginx/conf.d/

#RUN cp /etc/nginx/nginx.conf /nginx.conf \
#    && chmod +x /scripts/*.sh

CMD ["nginx", "-g", "daemon off;"]

# /etc/nginx/nginx.conf
# /usr/share/nginx/html
# /var/log/nginx
