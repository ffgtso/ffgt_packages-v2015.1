#!/bin/sh
# This script is supposed to be run every minute via cron.

# Sent WiFi info once. If geolocation isn't set, or if is_mobile node, fetch location and fill in geoloc data.
# If is_mobile, do this every 5 Minutes. Otherwise, it should be done once (until succeeded).
CURMIN=`/bin/date +%M`
MODULO=`/usr/bin/expr ${CURMIN} % 5`
mobile="`/sbin/uci get gluon-node-info.@location[0].is_mobile 2>/dev/null`"
if [ $? -eq 1 ]; then
 mobile=0
fi
runnow=0
isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

if [ ! -e /tmp/run/wifi-data-sent ]; then
 runnow=1
fi
if [ ${mobile} -eq 1 -a ${MODULO} -eq 0 ]; then
 runnow=1
fi

if [ ${runnow} -eq 1 ]; then
# Bloody v4/v6 issues ... From an IPv4-only upstream, the preferred IPv6 AAAA record results in connection errors.
 USEIPV4=1
 USEIPV6=0
 /bin/ping -q -c 3 setup.ipv4.guetersloh.freifunk.net >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  USEIPV4=0
  /bin/ping -q -c 3 setup.guetersloh.freifunk.net >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   USEIPV6=1
  fi
 fi
 if [ $USEIPV4 -eq 1 ]; then
  IPVXPREFIX="ipv4."
 else
  IPVXPREFIX=""
 fi
 # In theory, both of aboves checks could fail, e. g. on an unconnected node.
 # We might want to catch this case sometime ... (FIXME)
 # It might even be useful to just use an IPv6 ULA address for this (but we
 # actually want to get rid of ULA, so ...)

 mac=`/sbin/uci get network.bat0.macaddr`
 /usr/sbin/iw dev wlan0 scan >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  /sbin/ifconfig wlan0 up
  sleep 2
 fi
 /usr/bin/wget -q -O /dev/null "`/usr/sbin/iw dev wlan0 scan | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk`" && /bin/touch /tmp/run/wifi-data-sent
 # On success only ...
 if [ -e /tmp/run/wifi-data-sent ]; then
  curlat="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
  mobile="`/sbin/uci get gluon-node-info.@location[0].is_mobile 2>/dev/null`"
  if [ "X${curlat}" = "X" -o "X${mobile}" = "X1" ]; then
   sleep 10
   /usr/bin/wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}guetersloh.freifunk.net/geoloc.php?list=me&node=$mac"
   if [ -e /tmp/geoloc.out ]; then
    # Actually, we might want to sanity check the reply, as it could be empty or worse ... (FIXME)
    /bin/cat /dev/null >/tmp/geoloc.sh
    haslocation="`/sbin/uci get gluon-node-info.@location[0] 2>/dev/null]`"
    if [ "${haslocation}" != "location" ]; then
     echo "/sbin/uci add gluon-node-info location" >>/tmp/geoloc.sh
    fi
    # Honour existing share_location setting; if missing, create & set to '1'
    hasshare="`/sbin/uci get gluon-node-info.@location[0].share_location 1>/dev/null 2>&1; echo $?`"
    if [ "${hasshare}" != "0" ]; then
     echo "/sbin/uci set gluon-node-info.@location[0].share_location=1" >>/tmp/geoloc.sh
    fi
    grep "LAT: 0" </tmp/geoloc.out >/dev/null 2>&1
    if [ $? -ne 0 ]; then
     /usr/bin/awk </tmp/geoloc.out '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);} /^ADR:/ {printf("/sbin/uci set gluon-node-info.@location[0].addr=%c%s%c\n", 39, $2, 39);} /^CTY:/ {printf("/sbin/uci set gluon-node-info.@location[0].city=%s\n", $2);} /^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].locode=%s\n", $2); /^ZIP:/ {printf("/sbin/uci set gluon-node-info.@location[0].zip=%s\n", $2);} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
     /bin/sh /tmp/geoloc.sh
     if [ $isconfigured -ne 1 ]; then
      loc="`/sbin/uci get gluon-node-info.@location[0].locode 2>/dev/null`"
      adr="`/sbin/uci get gluon-node-info.@location[0].addr 2>/dev/null`"
      zip="`/sbin/uci get gluon-node-info.@location[0].zip 2>/dev/null`"
      if [ "x${loc}" != "x" -a "x${adr}" != "x" ]; then
       hostname="${zip}-${adr}"
       /sbin/uci set system.@system[0].hostname="${hostname}"
       /sbin/uci commit system
      fi
     fi
    fi
   fi
  fi
 fi
fi
