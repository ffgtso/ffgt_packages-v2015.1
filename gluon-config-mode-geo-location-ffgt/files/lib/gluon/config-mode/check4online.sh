#!/bin/sh

if [ ! -e /tmp/is_online ] ; then
 USEIPV4=1
 USEIPV6=0
 /bin/ping -q -c 3 setup.ipv4.4830.org >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  USEIPV4=0
  /bin/ping -q -c 3 setup.ipv6.4830.org >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   USEIPV6=1
  fi
 fi
 IPVXPREFIX="ipv6."
 if [ $USEIPV4 -eq 1 ]; then
  IPVXPREFIX="ipv4."
 fi
 if [ $USEIPV4 -eq 0 -a $USEIPV6 -eq 0 ]; then
   echo "$0: IPv5 not implemented."
   exit 1
 else
   echo "online with ${IPVXPREFIX}" >/tmp/is_online
 fi
fi