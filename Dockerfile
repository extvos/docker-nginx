FROM extvos/alpine-dev:latest
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"
ENV NGINX_VERSION=1.21.6
ENV NGINX_VOD_MODULE_VERSION=1.29
ENV NGINX_RTMP_MODULE_VERSION=v1.2.2

RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone -b ${NGINX_RTMP_MODULE_VERSION} https://github.com/arut/nginx-rtmp-module.git \
    && git clone -b ${NGINX_VOD_MODULE_VERSION} https://github.com/kaltura/nginx-vod-module.git


VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/sites.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache
VOLUME /var/log/nginx

EXPOSE 80 443 1935

# Init
CMD ["/sbin/nginx", "-c /etc/nginx/nginx.conf", "-g 'pid /run/nginx/nginx.pid; daemon off;'"]
