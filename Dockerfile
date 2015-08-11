FROM extvos/centos

MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"

ENV NGINX_VERSION 1.8.0
# 1.9.3
# http://nginx.org/download/nginx-1.9.3.tar.gz
# Installing packages.

RUN rpm -iUvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm \
	&& yum install -y nginx-${NGINX_VERSION}

RUN sed -i 's/^worker_processes.*/worker_processes\ 4;/g' /etc/nginx/nginx.conf \
	&& mkdir /var/lib/proxy_temp /var/lib/proxy_cache \
	&& chown -Rcf nginx.nginx /var/lib/proxy_temp /var/lib/proxy_cache

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/conf.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
