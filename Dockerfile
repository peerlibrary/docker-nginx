FROM cloyne/runit

MAINTAINER Mitar <mitar.docker@tnode.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER_HOST unix:///docker.sock

EXPOSE 80/tcp

RUN apt-get update -q -q && \
 apt-get install wget ca-certificates --yes --force-yes && \
 apt-get install nginx-full --yes --force-yes && \
 mkdir /etc/service/nginx && \
 /bin/echo -e '#!/bin/sh' > /etc/service/nginx/run && \
 /bin/echo -e 'exec /usr/sbin/nginx 2>&1' >> /etc/service/nginx/run && \
 chown root:root /etc/service/nginx/run && \
 chmod 755 /etc/service/nginx/run && \
 /bin/echo -e 'daemon off;' >> /etc/nginx/nginx.conf

COPY ./etc/conf.d/ /etc/nginx/conf.d/
COPY ./etc/sites-enabled/ /etc/nginx/sites-enabled/

RUN mkdir /dockergen && \
 wget -P /dockergen https://github.com/jwilder/docker-gen/releases/download/0.3.1/docker-gen-linux-amd64-0.3.1.tar.gz && \
 tar xvzf /dockergen/docker-gen-linux-amd64-0.3.1.tar.gz -C /dockergen && \
 mkdir /etc/service/dockergen && \
 /bin/echo -e '#!/bin/sh' > /etc/service/dockergen/run && \
 /bin/echo -e 'exec /dockergen/docker-gen -watch -only-exposed -notify "/usr/sbin/nginx -s reload" /dockergen/nginx.tmpl /etc/nginx/sites-enabled/virtual 2>&1' >> /etc/service/dockergen/run && \
 chown root:root /etc/service/dockergen/run && \
 chmod 755 /etc/service/dockergen/run && \
 mkdir /etc/service/dockergen/log && \
 mkdir /var/log/dockergen && \
 /bin/echo -e '#!/bin/sh' > /etc/service/dockergen/log/run && \
 /bin/echo -e 'exec chpst -unobody svlogd -tt /var/log/dockergen' >> /etc/service/dockergen/log/run && \
 chown root:root /etc/service/dockergen/log/run && \
 chmod 755 /etc/service/dockergen/log/run && \
 chown nobody:nogroup /var/log/dockergen

COPY ./etc/nginx.tmpl /dockergen/nginx.tmpl
