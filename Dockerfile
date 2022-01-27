FROM extvos/alpine-dev:latest AS builder
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"
ENV NGINX_VERSION=1.21.6
ENV NGINX_VOD_MODULE_VERSION=1.29
ENV NGINX_RTMP_MODULE_VERSION=v1.2.2

RUN apk update \
    && apk --update add openssl-dev pcre-dev zlib-dev wget build-base

RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone -b ${NGINX_RTMP_MODULE_VERSION} https://github.com/arut/nginx-rtmp-module.git \
    && git clone -b ${NGINX_VOD_MODULE_VERSION} https://github.com/kaltura/nginx-vod-module.git


RUN cd nginx-${NGINX_VERSION} \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/sbin/nginx \
        --modules-path=/usr/share/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --add-module=../nginx-rtmp-module \
        --add-module=../nginx-vod-module \
    && make && make install


FROM extvos/alpine:latest
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"

COPY --from=builder /sbin/nginx /sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

RUN apk update \
    && apk add --no-cache ca-certificates openssl pcre zlib tzdata \
    && mkdir -p /var/log/nginx/ /var/cache/nginx /etc/nginx/sites.d /etc/nginx/conf.d /etc/nginx/certs.d \
    && mv /etc/nginx/html /var/lib/nginx/html \
    && addgroup -S nginx \
    && adduser -S -D -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && rm -rf /var/cache/apk/*

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/sites.d/default.conf

VOLUME /etc/nginx/sites.d
VOLUME /etc/nginx/certs.d
VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /var/cache/nginx
VOLUME /var/lib/nginx/html

EXPOSE 80 443 1935

# Init
CMD ["/sbin/nginx", "-c", "/etc/nginx/nginx.conf", "-g", "pid /run/nginx/nginx.pid; daemon off;"]
