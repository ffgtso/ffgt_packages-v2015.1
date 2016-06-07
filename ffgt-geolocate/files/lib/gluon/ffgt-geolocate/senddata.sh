#!/bin/sh
# This script is supposed to be run every 1-5 minutes via cron.
#
# FIXME: do not uci commit all the time with is_mobile! That could kill the FLASH rather soonish :(
#
# Sent WiFi info once.
# If is_mobile node, fetch location and fill in geoloc data.
# If is_mobile, do this every 5 Minutes. Otherwise, it can be manually requested in config-mode.
CURMIN=`/bin/date +%M`
MODULO=`/usr/bin/expr ${CURMIN} % 5`
mobile="`/sbin/uci get gluon-node-info.@location[0].is_mobile 2>/dev/null`"
if [ $? -eq 1 ]; then
 mobile=0
fi
runnow=1
isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi
didenablewifi=0

if [ -e /tmp/run/wifi-data-sent ]; then
 runnow=0
fi

if [ $# -eq 1 ]; then
  forcerun=1
  runnow=1
else
  forcerun=0
fi

if [ ${mobile} -eq 1 -a ${MODULO} -eq 0 ]; then
 runnow=1
fi

if [ ${runnow} -eq 1 ]; then
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
 if [ $USEIPV4 -eq 1 ]; then
  IPVXPREFIX="ipv4."
 else
  IPVXPREFIX="ipv6."
 fi
 # In theory, both of aboves checks could fail, e. g. on an unconnected node.
 # We might want to catch this case sometime ... (FIXME)
 # It might even be useful to just use an IPv6 ULA address for this (but we
 # actually want to get rid of ULA, so ...)

 mac=`/sbin/uci get network.bat0.macaddr`
 # Fuuuu... iw might not be there. If so, let's fake it.
 if [ -e /usr/sbin/iw ]; then
  SCANIF="`/usr/sbin/iw dev | /usr/bin/awk 'BEGIN{idx=1;} /Interface / {iface[idx]=$2; ifacemap[$2]=idx; idx++}; END{if(ifacemap["mesh1"]>0) {printf("mesh1\n");} else if(ifacemap["wlan1"]>0) {printf("wlan1\n");} else if(ifacemap["mesh0"]>0) {printf("mesh0\n");} else if(ifacemap["wlan0"]>0) {printf("wlan0\n");} else {printf("%s\n", iface[idx-1]);}}'`"
  /usr/sbin/iw ${SCANIF} scan 2>/dev/null >/dev/null
  if [ $? -ne 0 ]; then
   /sbin/ifconfig ${SCANIF} up
   didenablewifi=1
   sleep 5
  fi
  /usr/bin/wget -q -O /dev/null "`/usr/sbin/iw dev ${SCANIF} scan | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk`" && /bin/touch /tmp/run/wifi-data-sent
 else
  /usr/bin/wget -q -O /dev/null "`cat /lib/gluon/ffgt-geolocate/iw-scan-dummy.data | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk`" && /bin/touch /tmp/run/wifi-data-sent
 fi
 if [ $didenablewifi == 1 ]; then
   /sbin/ifconfig ${SCANIF} down
   didenablewifi =0
 fi
 # On success only ...
 if [ -e /tmp/run/wifi-data-sent ]; then
  curlat="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
  mobile="`/sbin/uci get gluon-node-info.@location[0].is_mobile 2>/dev/null`"
  if [ "X${curlat}" = "X" -o "X${mobile}" = "X1" -o ${forcerun} -eq 1 ]; then
   /bin/cat /dev/null >/tmp/geoloc.sh
   sleep 2
   /usr/bin/wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}4830.org/geoloc.php?list=me&node=$mac"
   if [ -e /tmp/geoloc.out ]; then
    # Actually, we might want to sanity check the reply, as it could be empty or worse ... (FIXME)
    haslocation="`/sbin/uci get gluon-node-info.@location[0] 2>/dev/null]`"
    if [ "${haslocation}" != "location" ]; then
     echo "/sbin/uci add gluon-node-info location" >>/tmp/geoloc.sh
    fi
    # Honour existing share_location setting; if missing, create & set to '1'
    hasshare="`/sbin/uci get gluon-node-info.@location[0].share_location >/dev/null 2>&1; echo $?`"
    if [ "${hasshare}" != "0" ]; then
     echo "/sbin/uci set gluon-node-info.@location[0].share_location=1" >>/tmp/geoloc.sh
    fi
    grep "LAT: 0" </tmp/geoloc.out >/dev/null 2>&1
    if [ $? -ne 0 ]; then
     /usr/bin/awk </tmp/geoloc.out '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);}' >>/tmp/geoloc.sh
     /usr/bin/awk </tmp/geoloc.out '/^ADR:/ {printf("/sbin/uci set gluon-node-info.@location[0].addr=%c%s%c\n", 39, substr($0, 6), 39);} /^CTY:/ {printf("/sbin/uci set gluon-node-info.@location[0].city=%c%s%c\n", 39, substr($0, 6), 39);}' >>/tmp/geoloc.sh
     /usr/bin/awk </tmp/geoloc.out '/^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].locode=%s\n", $2)}; /^ZIP:/ {printf("/sbin/uci set gluon-node-info.@location[0].zip=%s\n", $2);} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
     if [ ${mobile} -eq 1 -o ${forcerun} -eq 1 ]; then
      /bin/sh /tmp/geoloc.sh
      if [ $isconfigured -ne 1 ]; then
       loc="`/sbin/uci get gluon-node-info.@location[0].locode 2>/dev/null`"
       adr="`/sbin/uci get gluon-node-info.@location[0].addr 2>/dev/null`"
       zip="`/sbin/uci get gluon-node-info.@location[0].zip 2>/dev/null`"
       if [ "x${zip}" != "x" -a "x${adr}" != "x" ]; then
        nodeid=`echo "util=require 'gluon.util' print(string.format('%s', string.sub(util.node_id(), 9)))" | /usr/bin/lua`
        suffix=`echo "util=require 'gluon.util' print(string.format('%s', string.sub(util.node_id(), 9)))" | /usr/bin/lua`
        hostname="${zip}-${adr}-${suffix}"
        #hostname="${zip}-freifunk-${nodeid}"
        /sbin/uci set system.@system[0].hostname="${hostname}"
        /sbin/uci commit system
       fi # "x${zip}"
      fi # $isconfigured -ne 1
     fi # ${mobile} -eq 1
    fi # LAT not 0
   fi
  fi
 fi
fi
