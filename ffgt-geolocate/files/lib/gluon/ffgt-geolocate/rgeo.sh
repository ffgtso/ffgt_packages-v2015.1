#!/bin/sh

isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

IPVXPREFIX="`/lib/gluon/ffgt-geolocate/ipv5.sh`"
if [ "Y$IPVXPREFIX" == "Y" -o "$IPVXPREFIX" == "ipv5." ]; then
 logger "$0: IPv5 not implemented."
 exit 1
fi

mac=`/sbin/uci get network.bat0.macaddr`
curlat="`/sbin/uci get gluon-node-info.@location[0].latitude 2>/dev/null`"
curlon="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
if [ "X${curlat}" != "X" -a "X${curlon}" != "X" ]; then
 /usr/bin/wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}4830.org/geoloc.php?rgeo=me&node=${mac}&lat=${curlat}&lon=${curlon}"
 if [ -e /tmp/geoloc.out ]; then
  # Actually, we might want to sanity check the reply, as it could be empty or worse ... (FIXME)
  grep "LAT: 0$" </tmp/geoloc.out >/dev/null 2>&1
  if [ $? -ne 0 ]; then
   /bin/cat /dev/null >/tmp/geoloc.sh
   /usr/bin/awk </tmp/geoloc.out '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);}' >>/tmp/geoloc.sh
   /usr/bin/awk </tmp/geoloc.out '/^ADR:/ {printf("/sbin/uci set gluon-node-info.@location[0].addr=%c%s%c\n", 39, substr($0, 6), 39);} /^CTY:/ {printf("/sbin/uci set gluon-node-info.@location[0].city=%c%s%c\n", 39, substr($0, 6), 39);}' >>/tmp/geoloc.sh
   /usr/bin/awk </tmp/geoloc.out '/^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].locode=%s\n", $2)}; /^ZIP:/ {printf("/sbin/uci set gluon-node-info.@location[0].zip=%s\n", $2);} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
   /bin/sh /tmp/geoloc.sh
   loc="`/sbin/uci get gluon-node-info.@location[0].locode 2>/dev/null`"
   adr="`/sbin/uci get gluon-node-info.@location[0].addr 2>/dev/null`"
   zip="`/sbin/uci get gluon-node-info.@location[0].zip 2>/dev/null`"
   if [ $isconfigured -ne 1 ]; then
     if [ "x${zip}" != "x" -a "x${adr}" != "x" ]; then
      nodeid=`echo "util=require 'gluon.util' print(string.format('%s', string.sub(util.node_id(), 9)))" | /usr/bin/lua`
      suffix=`echo "util=require 'gluon.util' print(string.format('%s', string.sub(util.node_id(), 9)))" | /usr/bin/lua`
      hostname="${zip}-${adr}-${suffix}"
      #hostname="${zip}-freifunk-${nodeid}"
      /sbin/uci set system.@system[0].hostname="${hostname}"
      /sbin/uci commit system
     fi
   fi
   #/bin/rm -rf /tmp/luci-modulecache/*
  fi
 fi
fi
