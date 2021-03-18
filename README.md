# docker-nginx
Dockerfile for Nginx based on Alpine Linux with consul-template enabled.

## Exposed ports: `80`, `443`

## Exposed -s

- /usr/share/nginx/html
  Default web root.
- /etc/nginx/modules.d
  Module configs.
- /etc/nginx/conf.d
  Global configs.
- /etc/nginx/sites.templates
  Templates of consule-template, which allow to generate configs to sites.d
- /etc/nginx/sites.d
  Sites configs.
- /var/lib/proxy_temp
  Reverse proxy temp folder
- /var/lib/proxy_cache
  Reverse proxy cache folder
- /var/log/nginx
  Log file volume


