#!/bin/sh
set -e

## Start nginx
nginx -g "daemon off;" &

## Start consult-template if CONSUL_ADDR was assigned
if [ -n "${CONSUL_ADDR}" ]; then
    /usr/local/bin/consul-template -consul-addr=${CONSUL_ADDR} -config=/etc/consul.cfg &
fi

