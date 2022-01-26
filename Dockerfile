FROM extvos/alpine:latest
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"

RUN apk update && apk add --no-cache nginx nginx-doc \
    && apk list -P nginx-mod-* | grep -o '<[a-z0-9-]*>' | sed 's/[<|>]//g' | xargs apk add --no-cache \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig

ADD nginx.conf /etc/nginx/nginx.conf

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
	&& rm -rf /etc/nginx/conf.d/* && mkdir /etc/nginx/modules.d 
#    && mv /etc/nginx/html /var/lib/nginx/html


# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log


VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/sites.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache
VOLUME /var/lib/nginx/html
VOLUME /var/log/nginx

EXPOSE 80 443 1935

# Init
CMD ["/sbin/nginx", "-c /etc/nginx/nginx.conf", "-g 'pid /run/nginx/nginx.pid; daemon off;'"]
