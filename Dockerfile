FROM extvos/alpine
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"
ENV NGINX_VERSION 1.10.1

RUN apk update && apk add nginx

RUN sed -i 's/^worker_processes.*/worker_processes\ 4;/g' /etc/nginx/nginx.conf \
	&& mkdir -p /var/lib/proxy_temp /var/lib/proxy_cache /run/nginx /var/log/nginx \
	&& chown -Rcf nginx.nginx /var/lib/proxy_temp /var/lib/proxy_cache /run/nginx/ /var/log/nginx

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/default.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
