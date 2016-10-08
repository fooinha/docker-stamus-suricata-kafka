FROM stamus/suricata
MAINTAINER fooinha <fooinha@gmail.com>

ARG SURICATA_DEBIAN_KAFKA_VERSION=3.2.0-1+beta1~kafka

COPY suricata_${SURICATA_DEBIAN_KAFKA_VERSION}_amd64.deb /root

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils
RUN echo "deb http://httpredir.debian.org/debian sid main" > /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python libcap-ng0 libgcrypt20 libgeoip1 libgnutls30 libhiredis0.13 libjansson4 libluajit-5.1-2 libmagic1 libnet1 libnetfilter-log1 libnetfilter-queue1 libnfnetlink0 libnspr4 libnss3 libpcap0.8 libpcre3 libprelude2 librdkafka1 libyaml-0-2 zlib1g supervisor python-pyinotify psmisc ethtool tcpflow vim ngrep curl

RUN dpkg -i /root/suricata_${SURICATA_DEBIAN_KAFKA_VERSION}_amd64.deb

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
