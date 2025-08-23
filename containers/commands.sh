#!/bin/bash
# TODO Rework containers name. I think use of underscores
# TODO Rework build images names and tags
PROJECT_DIR="${HOME}/GolandProjects/valetainer"
CONTAINERS_DIR="${PROJECT_DIR}/containers"

LOG_BEGIN="\n| ------------------------ |\n|\n|\n|\n|-- "
LOG_END="\n|\n|\n|\n| ------------------------ |\n"

if [ "$(id -u)" -eq 0 ];
then
    echo -e "${LOG_BEGIN} /!\ You started this command with sudo ! Please re-run without.\nExiting...${LOG_END}"
    exit
fi

USER_UID=$(id -u)

CONTAINER_ENGINE=docker
INTERNAL_HOSTNAME="--hostname"
IMAGES_PREFIX=""
BIND_MOUNT_NAMESPACE_KEEP_ID=""
if command -v podman > /dev/null 2>&1
then
    CONTAINER_ENGINE=podman
    INTERNAL_HOSTNAME="--network-alias"
    IMAGES_PREFIX="localhost/"
    BIND_MOUNT_NAMESPACE_KEEP_ID="--userns=keep-id"
fi
echo -e "${LOG_BEGIN} Current user UID: $USER_UID\n|--  Using ${CONTAINER_ENGINE} as containerization engine ${LOG_END}"



# --- Cleanup
echo -e "${LOG_BEGIN} Removing containers ... ${LOG_END}"
containers=(
    # Global
    "valetainer-pma"
    "valetainer-nginx"
    "valetainer-dnsmasq"
    # Stack one
    "valetainer-test-laravel-mariadb"
    "valetainer-test-laravel-php"
    "valetainer-test-laravel-web"
    # Stack two
    "valetainer-test-mariadb"
    "valetainer-test-php"
    "valetainer-test-web"
)
for container in "${containers[@]}"; do
    "${CONTAINER_ENGINE}" container stop "${container}" && "${CONTAINER_ENGINE}" container rm --volumes "${container}"
    echo
done

echo -e "${LOG_BEGIN} Removing networks ... ${LOG_END}"
"${CONTAINER_ENGINE}" network rm valetainer-proxy
"${CONTAINER_ENGINE}" network rm valetainer-test-laravel
"${CONTAINER_ENGINE}" network rm valetainer-test

# Remove images
echo -e "${LOG_BEGIN} Removing images ... ${LOG_END}"
images=(
    "valetainer-pma:beta"
    "valetainer-mariadb:beta"
    "valetainer-php:beta"
    "valetainer-nginx-web:beta"
    "valetainer-nginx-proxy:beta"
    "valetainer-dnsmasq:beta"
)
for image in "${images[@]}"; do
    "${CONTAINER_ENGINE}" image rm "${IMAGES_PREFIX}${image}"
    echo
done

# Build images
echo -e "${LOG_BEGIN} Building docker images ... ${LOG_END}"
cd "$CONTAINERS_DIR/phpmyadmin" || (echo "PHPMyAdmin build file directory not found ! Exiting..." && exit)
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-pma:beta" \
    -f pma.Dockerfile .
echo -e "\n\n"

cd "$CONTAINERS_DIR/databases" || (echo "Database build file directory not found ! Exiting..." && exit)
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-mariadb:beta" \
    -f maria.Dockerfile .
echo -e "\n\n"

cd "$CONTAINERS_DIR/php" || (echo "PHP build file directory not found ! Exiting..." && exit)
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-php:beta" \
    --build-arg USER_UID="$USER_UID" \
    -f php.Dockerfile .
echo -e "\n\n"

cd "$CONTAINERS_DIR/nginx" || (echo "NGINX build file directory not found ! Exiting..." && exit)
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-nginx-web:beta" \
    -f site.nginx.Dockerfile .
echo -e "\n\n"
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-nginx-proxy:beta" \
    -f proxy.nginx.Dockerfile .
echo -e "\n\n"

cd "$CONTAINERS_DIR/dnsmasq" || (echo "DNSMASQ build file directory not found ! Exiting..." && exit)
"${CONTAINER_ENGINE}" image build -t "${IMAGES_PREFIX}valetainer-dnsmasq:beta" \
    -f dnsmasq.Dockerfile .
echo -e "\n\n"

# --- Network
echo -e "${LOG_BEGIN} Setting up global network ... ${LOG_END}"
"${CONTAINER_ENGINE}" network create valetainer-proxy \
    --driver=bridge \
    --subnet 172.26.0.0/22



# --- Stack one https://test-laravel.test
echo -e "${LOG_BEGIN} Deploying stack number one (test-laravel.test) ... ${LOG_END}"
"${CONTAINER_ENGINE}" network create valetainer-test-laravel \
    --driver=bridge

"${CONTAINER_ENGINE}" run \
    --network valetainer-test-laravel \
    --restart always \
    --name "valetainer-test-laravel-mariadb" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-laravel-mariadb" \
    -d "valetainer-mariadb:beta"

"${CONTAINER_ENGINE}" run $BIND_MOUNT_NAMESPACE_KEEP_ID \
    --network valetainer-test-laravel \
    --restart always \
    --name "valetainer-test-laravel-php" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-laravel-php" \
    --volume "${HOME}/ValetainerProjects":/ValetainerProjects \
    -d "valetainer-php:beta"

"${CONTAINER_ENGINE}" run $BIND_MOUNT_NAMESPACE_KEEP_ID \
    --network valetainer-proxy \
    --network valetainer-test-laravel \
    --restart always \
    --name "valetainer-test-laravel-web" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-laravel-web" \
    --volume "${HOME}/ValetainerProjects":/ValetainerProjects \
    --volume "${PROJECT_DIR}/containers/nginx/sites.conf.d/sites/project-test-laravel.conf":/etc/nginx/conf.d/site.conf \
    -d "valetainer-nginx-web:beta"
# Later the container will be passed ENV variables and the entrypoint will be charged to complete a generic conf template
# instead of bind mounting a specific file from the host ?
# But no, bacause I wan't to allow users curstomize the file (by keeping "template variables")



# --- Stack two https://test.test
echo -e "${LOG_BEGIN} Deploying stack number two (test.test) ... ${LOG_END}"
"${CONTAINER_ENGINE}" network create valetainer-test \
    --driver=bridge

"${CONTAINER_ENGINE}" run \
    --network valetainer-test \
    --restart always \
    --name "valetainer-test-mariadb" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-mariadb" \
    -d "valetainer-mariadb:beta"

"${CONTAINER_ENGINE}" run $BIND_MOUNT_NAMESPACE_KEEP_ID \
    --network valetainer-test \
    --restart always \
    --name "valetainer-test-php" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-php" \
    --volume "${HOME}/ValetainerProjects":/ValetainerProjects \
    -d "valetainer-php:beta"

"${CONTAINER_ENGINE}" run $BIND_MOUNT_NAMESPACE_KEEP_ID \
    --network valetainer-proxy \
    --network valetainer-test \
    --restart always \
    --name "valetainer-test-web" \
    "${INTERNAL_HOSTNAME}" "valetainer-test-web" \
    --volume "${HOME}/ValetainerProjects":/ValetainerProjects \
    --volume "${PROJECT_DIR}/containers/nginx/sites.conf.d/sites/project-test.conf":/etc/nginx/conf.d/site.conf \
    -d "valetainer-nginx-web:beta"


# --- Global containers
echo -e "${LOG_BEGIN} Deploying global containers ... ${LOG_END}"
"${CONTAINER_ENGINE}" run \
    --network valetainer-proxy \
    --restart always \
    --name "valetainer-pma" \
    "${INTERNAL_HOSTNAME}" "valetainer-pma" \
    -d "valetainer-pma:beta"

"${CONTAINER_ENGINE}" run \
    --network valetainer-proxy \
    --restart always \
    --name "valetainer-nginx" \
    "${INTERNAL_HOSTNAME}" "valetainer-nginx" \
    --cap-add CAP_NET_BIND_SERVICE \
    -p "127.0.0.1:80:80" \
    -p "127.0.0.1:443:443" \
    -d "valetainer-nginx-proxy:beta"

"${CONTAINER_ENGINE}" run \
    --network valetainer-proxy \
    --restart always \
    --name "valetainer-dnsmasq" \
    "${INTERNAL_HOSTNAME}" "valetainer-dnsmasq" \
    --cap-add CAP_NET_BIND_SERVICE \
    -p "127.0.0.1:53:53/udp" \
    -d "valetainer-dnsmasq:beta"

sleep 2
echo -e "\n\n\n\n"
"${CONTAINER_ENGINE}" ps -a
