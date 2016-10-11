# vim:set ft=dockerfile:
FROM alpine:latest
MAINTAINER DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' 

### Install Application
RUN apk --no-cache upgrade && \
    apk add --no-cache --virtual=build-deps \
      gcc \
      jpeg-dev \
      python-dev \
      musl-dev \
      py-pip \
      zlib-dev && \
    apk add --no-cache --virtual=run-deps \
      python \ 
      jpeg \
      ssmtp \
      su-exec && \
    pip --no-cache-dir install --upgrade setuptools && \
    pip --no-cache-dir install --upgrade mezzanine gunicorn && \
    apk del --no-cache --purge \
      build-deps  && \
    rm -rf /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*

### Volume
VOLUME ["/project"]

### Expose ports
EXPOSE 8000

### Running User: not used, managed by docker-entrypoint.sh
#USER mezzanine

### Start Mezzanine
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mezzanine"]
