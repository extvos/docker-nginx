FROM extvos/alpine:latest
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"

RUN apk update && apk add --no-cache nginx nginx-doc \
    && apk list -P nginx-mod-* | grep -o '<[a-z0-9-]*>' | sed 's/[<|>]//g' | xargs apk add --no-cache \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig \
    && mv /etc/nginx/modules.d /etc/nginx/modules.installed

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/lib/proxy_temp \
             /var/lib/proxy_cache \
             /run/nginx \
             /var/log/nginx \
             /etc/nginx/conf.d \
             /etc/nginx/sites.d \
	&& chown -Rcf nginx.nginx \
	         /var/lib/proxy_temp \
	         /var/lib/proxy_cache \
	         /run/nginx/ \
	         /var/log/nginx \
	&& rm -rf /etc/nginx/conf.d/* && mv /etc/nginx/modules /etc/nginx/modules.d

COPY default.conf /etc/nginx/sites.d/default.conf
# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/sites.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
