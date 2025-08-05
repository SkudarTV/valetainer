FROM docker.io/library/debian:12.11
LABEL authors="valetainer"

RUN apt update \
    && apt install dnsmasq -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./dnsmasq.conf /etc/dnsmasq.d/valetainer.conf

ENTRYPOINT ["dnsmasq", "--no-daemon", "--conf-file=/etc/dnsmasq.d/valetainer.conf"]
