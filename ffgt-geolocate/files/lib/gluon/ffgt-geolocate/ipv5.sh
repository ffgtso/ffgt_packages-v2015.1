#!/bin/sh

# Do a reverse geocoding with current lat/lon settings
# Bloody v4/v6 issues ... From an IPv4-only upstream, the preferred IPv6 AAAA record results in connection errors.
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
  #echo "$0: IPv5 not implemented."
  IPVXPREFIX="ipv5."
fi

echo $IPVXPREFIX
exit 0
