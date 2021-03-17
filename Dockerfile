FROM extvos/alpine:latest
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"
ENV CONSUL_TEMPLATE_VERSION=0.25.2
RUN apk update && \
    apk add --no-cache tini nginx \
						nginx-doc \
            nginx-mod-http-lua-upstream \
            nginx-mod-http-lua \
            nginx-mod-rtmp \
            nginx-mod-http-image-filter \
            nginx-mod-http-set-misc \
            nginx-mod-stream && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig

ADD nginx.conf /etc/nginx/nginx.conf
ADD entrypoint.sh /entrypoint.sh

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
	&& rm -rf /etc/nginx/conf.d/* && mkdir /etc/nginx/modules.d \
  && chmod +x /entrypoint.sh

ARG CONSULE_RELEASE=https://releases.hashicorp.com/consul-template/0.25.2/consul-template_0.25.2_linux_amd64.tgz
ENV CONSULE_RELEASE=${CONSULE_RELEASE}
ADD ${CONSULE_RELEASE} /tmp/consul-template.tgz

ADD consul.d/default.cfg /etc/consul.cfg
ADD default.conf /etc/nginx/sites.d/default.conf

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
RUN tar zxf /tmp/consul-template.tgz -C /usr/local/bin && rm -f /tmp/consul-template.tgz

VOLUME /usr/share/nginx/html
VOLUME /etc/nginx/modules.d
VOLUME /etc/nginx/conf.d
VOLUME /etc/nginx/sites.templates
VOLUME /etc/nginx/sites.d
VOLUME /var/lib/proxy_temp
VOLUME /var/lib/proxy_cache
VOLUME /var/log/nginx

EXPOSE 80 443
USER nginx
CMD ["/sbin/tini", "--", "/entrypoint.sh"]