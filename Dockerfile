FROM extvos/alpine:s6
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"

RUN apk update && apk add --no-cache nginx \
						  nginx-doc \
                          nginx-mod-http-lua-upstream \
                          nginx-mod-http-lua \
                          nginx-mod-rtmp \
                          nginx-mod-http-image-filter \
                          nginx-mod-http-set-misc \
                          nginx-mod-stream \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig

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
	&& rm -rf /etc/nginx/conf.d/* && mkdir /etc/nginx/modules.d

ADD fix-attrs.d /etc/fix-attrs.d
ADD services.d /etc/services.d

COPY default.conf /etc/nginx/sites.d/default.conf
# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/sites.templates
VOLUME /etc/nginx/sites.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache
VOLUME /var/log/nginx

EXPOSE 80 443
