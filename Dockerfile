FROM cloyne/runit

MAINTAINER Mitar <mitar.docker@tnode.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q -q

RUN apt-get install wget ca-certificates --yes --force-yes

RUN apt-get install nginx-full --yes --force-yes

EXPOSE 80/tcp
ENV DOCKER_HOST unix:///docker.sock

RUN mkdir /etc/service/nginx
RUN /bin/echo -e '#!/bin/sh' > /etc/service/nginx/run
RUN /bin/echo -e 'exec /usr/sbin/nginx 2>&1' >> /etc/service/nginx/run
RUN chown root:root /etc/service/nginx/run
RUN chmod 755 /etc/service/nginx/run

RUN /bin/echo -e 'daemon off;' >> /etc/nginx/nginx.conf

COPY ./etc/conf.d/ /etc/nginx/conf.d/
COPY ./etc/sites-enabled/ /etc/nginx/sites-enabled/

RUN mkdir /dockergen
WORKDIR /dockergen
COPY ./etc/nginx.tmpl /dockergen/nginx.tmpl
RUN wget https://github.com/jwilder/docker-gen/releases/download/0.3.1/docker-gen-linux-amd64-0.3.1.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.3.1.tar.gz

RUN mkdir /etc/service/dockergen
RUN /bin/echo -e '#!/bin/sh' > /etc/service/dockergen/run
RUN /bin/echo -e 'exec /dockergen/docker-gen -watch -only-exposed -notify "/usr/sbin/nginx -s reload" /dockergen/nginx.tmpl /etc/nginx/sites-enabled/virtual 2>&1' >> /etc/service/dockergen/run
RUN chown root:root /etc/service/dockergen/run
RUN chmod 755 /etc/service/dockergen/run

RUN mkdir /etc/service/dockergen/log
RUN mkdir /var/log/dockergen
RUN /bin/echo -e '#!/bin/sh' > /etc/service/dockergen/log/run
RUN /bin/echo -e 'exec chpst -unobody svlogd -tt /var/log/dockergen' >> /etc/service/dockergen/log/run
RUN chown root:root /etc/service/dockergen/log/run
RUN chmod 755 /etc/service/dockergen/log/run
RUN chown nobody:nogroup /var/log/dockergen
