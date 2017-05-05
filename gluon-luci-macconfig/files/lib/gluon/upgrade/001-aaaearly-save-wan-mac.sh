#!/bin/sh

( WANMAC="`uci get network.wan.macaddr`" ; \
 if [ ! -z "${WANMAC}" ]; then \
  uci get system.@system[0].staticwanmac || uci set system.@system[0].staticwanmac="${WANMAC}" ;\
  uci commit ;\
 fi ) >/dev/null 2>&1
