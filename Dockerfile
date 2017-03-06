FROM java:latest

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV VERSION 3.2.0

ENV OPENMEETINGS_HOME /opt/openmeetings

RUN mkdir -p $OPENMEETINGS_HOME && \
    cd $OPENMEETINGS_HOME && \
    wget http://apache.crihan.fr/dist/openmeetings/$VERSION/bin/apache-openmeetings-$VERSION.tar.gz && \
    tar zxf apache-openmeetings-$VERSION.tar.gz && \
    rm -f apache-openmeetings-$VERSION.tar.gz

RUN apt-get update && \
    apt-get install -y \
        swftools \
        ffmpeg \
        ghostscript \
        imagemagick \
        xmlstarlet

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /

EXPOSE 5080 1935 8081 8100 8088 8443 5443

WORKDIR cd $OPENMEETINGS_HOME

CMD ["/docker-entrypoint.sh"]
