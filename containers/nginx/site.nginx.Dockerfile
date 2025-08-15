#FROM docker.io/nginx:1.29-alpine
FROM docker.io/nginxinc/nginx-unprivileged:1.29-alpine
LABEL authors="valetainer"

USER root
RUN mkdir /ValetainerProjects \
    && chown nginx:nginx /ValetainerProjects

USER 101
WORKDIR /ValetainerProjects

CMD ["nginx", "-g", "daemon off;"]

# /etc/nginx/nginx.conf
# /etc/nginx/conf.d/
# /var/log/nginx
