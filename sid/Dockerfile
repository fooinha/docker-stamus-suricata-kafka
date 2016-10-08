FROM debian:sid
MAINTAINER fooinha <fooinha@gmail.com>

ARG DEBIAN_REPO_HOST=ftp.pt.debian.org
ARG SURICATA_DEBIAN_SID_VERSION=3.1.2-2
ARG SURICATA_DEBIAN_KAFKA_VERSION=3.2.0-1+beta1~kafka
ARG SURICATA_GIT_BRANCH=dev-eve-ouput-kafka-v2

# Mirror to my location
RUN echo "deb http://${DEBIAN_REPO_HOST}/debian sid main" > /etc/apt/sources.list
RUN echo "deb-src http://${DEBIAN_REPO_HOST}/debian sid main" >> /etc/apt/sources.list

# Update
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install build dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing \
    apt-utils \
    git-core \
    build-essential \
    devscripts \
    make \
    valgrind \
    autoconf \
    automake \
    dh-autoreconf \
    libtool \
    libpcap-dev \
    libnet1-dev \
    libyaml-0-2 \
    libyaml-dev \
    zlib1g \
    zlib1g-dev \
    libcap-ng-dev \
    libcap-ng0 \
    libpcre3 \
    libpcre3-dbg \
    libpcre3-dev \
    libmagic-dev \
    libnetfilter-queue-dev \
    libnetfilter-queue1 \
    libnfnetlink-dev \
    libnetfilter-log-dev \
    libprelude-dev \
    libnfnetlink0 \
    libjansson-dev \
    libnss3-dev \
    libnspr4-dev \
    libgeoip1 \
    libgeoip-dev \
    libluajit-5.1-common \
    libluajit-5.1-dev \
    libhiredis-dev \
    librdkafka-dev \
    python \
    wget \
    jq \
    vim \
    tcpdump \
    ngrep \
    bind9-host

WORKDIR /root

# Clone source from git repository
RUN git clone -v -b ${SURICATA_GIT_BRANCH} --single-branch https://github.com/fooinha/suricata.git
RUN cd suricata ; git checkout ${SURICATA_GIT_BRANCH}
RUN mv suricata suricata-${SURICATA_DEBIAN_KAFKA_VERSION}
RUN tar cf suricata-${SURICATA_DEBIAN_KAFKA_VERSION}.tar suricata-${SURICATA_DEBIAN_KAFKA_VERSION}/
RUN gzip suricata-${SURICATA_DEBIAN_KAFKA_VERSION}.tar

# Get debian package source
RUN DEBIAN_FRONTEND=noninteractive apt-get source suricata=$SURICATA_DEBIAN_SID_VERSION
RUN xz -d suricata_${SURICATA_DEBIAN_SID_VERSION}.debian.tar.xz ; tar xvf suricata_${SURICATA_DEBIAN_SID_VERSION}.debian.tar

# Copy debian directory to build dir
RUN mv debian suricata-${SURICATA_DEBIAN_KAFKA_VERSION}/

RUN sed -i -e 's/--enable-hiredis/--enable-hiredis --enable-rdkafka/' suricata-${SURICATA_DEBIAN_KAFKA_VERSION}/debian/rules

WORKDIR /root/suricata-${SURICATA_DEBIAN_KAFKA_VERSION}/

# Get libhtp from git
RUN git clone -v https://github.com/OISF/libhtp

# Changelog
RUN DEBFULLNAME=fooinha DEBEMAIL=fooinha@gmail.com dch  -v ${SURICATA_DEBIAN_KAFKA_VERSION} -D unstable "Experimental version of suricata 3.2.0beta with kafka output."

# Configure with default filetype to kafka
RUN sed -i -e 's/filetype: regular #regular/filetype: kafka #regular/' suricata.yaml.in
RUN sed -i -e 's/#kafka/kafka/' suricata.yaml.in
RUN sed -i -e 's/#  broker-list: 127.0.0.1:9092/   broker-list: kafka:9092/' suricata.yaml.in
RUN sed -i -e 's/#  topic: suricata/   topic: suricata/' suricata.yaml.in
RUN sed -i -e 's/#  compression: snappy/   compression: snappy/' suricata.yaml.in
RUN sed -i -e 's/#  partition: -1/   partition: 0/' suricata.yaml.in

# Build package
RUN ./debian/rules binary

RUN dpkg -I ../suricata_${SURICATA_DEBIAN_KAFKA_VERSION}_amd64.deb

CMD ["/bin/bash"]
