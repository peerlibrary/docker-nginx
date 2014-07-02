FROM cloyne/runit

MAINTAINER Mitar <mitar.docker@tnode.com>

EXPOSE 80/tcp

RUN apt-get update -q -q && \
 apt-get install nginx-full --yes --force-yes && \
 mkdir /etc/service/nginx && \
 /bin/echo -e '#!/bin/sh' > /etc/service/nginx/run && \
 /bin/echo -e "echo \"resolver \$(grep nameserver /etc/resolv.conf | awk '{print \$2}') valid=5s;\" > /etc/nginx/conf.d/resolver.conf" >> /etc/service/nginx/run && \
 /bin/echo -e "if [ \"\$SET_REAL_IP_FROM\" ]; then echo \"set_real_ip_from \$SET_REAL_IP_FROM;\" > /etc/nginx/conf.d/set_real_ip_from.conf; fi" >> /etc/service/nginx/run && \
 /bin/echo -e 'exec /usr/sbin/nginx 2>&1' >> /etc/service/nginx/run && \
 chown root:root /etc/service/nginx/run && \
 chmod 755 /etc/service/nginx/run && \
 /bin/echo -e 'daemon off;' >> /etc/nginx/nginx.conf && \
 sed -i 's/\/\$nginx_version//' /etc/nginx/fastcgi_params && \
 touch /etc/nginx/sites-available/NOT_USED

COPY ./etc/conf.d/ /etc/nginx/conf.d/
COPY ./etc/sites-enabled/ /etc/nginx/sites-enabled/
