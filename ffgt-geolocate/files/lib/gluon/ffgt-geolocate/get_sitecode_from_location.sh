#!/bin/sh

isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
 logger "$0: please configure the system first."
 exit 1
fi

IPVXPREFIX="`/lib/gluon/ffgt-geolocate/ipv5.sh`"
DATAFILE="/tmp/geoloc-$$.out"
LOCKFILE="/tmp/sitecode_set"

if [ "Y$IPVXPREFIX" == "Y" -o "$IPVXPREFIX" == "ipv5." ]; then
 logger "$0: IPv5 not implemented."
 exit 1
fi

if [ -e ${LOCKFILE} ]; then
 logger "$0: ${LOCKFILE} exists ... Only running (successfully) once per powercycle."
 exit 0
fi

mac=`/sbin/uci get network.bat0.macaddr`
curlat="`/sbin/uci get gluon-node-info.@location[0].latitude 2>/dev/null`"
curlon="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
if [ "X${curlat}" != "X" -a "X${curlon}" != "X" ]; then
 /usr/bin/wget -q -O ${DATAFILE} "http://setup.${IPVXPREFIX}4830.org/geoloc.php?rgeo=me&node=${mac}&lat=${curlat}&lon=${curlon}"
 if [ -e ${DATAFILE} ]; then
  # Actually, we might want to sanity check the reply, as it could be empty or worse ... (FIXME)
  grep "LAT: 0$" <${DATAFILE} >/dev/null 2>&1
  if [ $? -ne 0 ]; then
   newsitecode="`/usr/bin/awk <${DATAFILE} '/^LOC:/ {printf("%s", $2);}'`"
   siteselect="`/sbin/uci get gluon-node-info.@location[0].siteselect 2>/dev/null`"
   # Sanity check: only tamper with settings if the sitecode actually differs
   if [ "X${newsitecode}" != "X" -a "${newsitecode}" != "${siteselect}" ]; then
    /bin/cat /dev/null >/tmp/geoloc.sh
    /usr/bin/awk <${DATAFILE} '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);}' >>/tmp/geoloc.sh
    /usr/bin/awk <${DATAFILE} '/^ADR:/ {printf("/sbin/uci set gluon-node-info.@location[0].addr=%c%s%c\n", 39, substr($0, 6), 39);} /^CTY:/ {printf("/sbin/uci set gluon-node-info.@location[0].city=%c%s%c\n", 39, substr($0, 6), 39);}' >>/tmp/geoloc.sh
    /usr/bin/awk <${DATAFILE} '/^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].locode=%s\n", $2)}; /^ZIP:/ {printf("/sbin/uci set gluon-node-info.@location[0].zip=%s\n", $2);}' >>/tmp/geoloc.sh
    /usr/bin/awk <${DATAFILE} '/^LOC:/ {printf("/sbin/uci set gluon-node-info.@location[0].siteselect=%s\n", $2); printf("/sbin/uci set gluon-node-info.@location[0].siteselect_source=script\n");} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
    /bin/sh /tmp/geoloc.sh
    siteselect="`/sbin/uci get gluon-node-info.@location[0].siteselect 2>/dev/null`"
    if [ "X${siteselect}" != "X" ]; then
     srcfile="`/sbin/uci get siteselect.${siteselect}.path 2>/dev/null`"
     if [ "X${srcfile}" != "X" ]; then
      logger "$0: src=\"${srcfile}\" com=\"${siteselect}\""
      /bin/cp "${srcfile}" /lib/gluon/site.conf
      (/lib/gluon/site-upgrade &)
     fi
    fi
   fi
   /bin/touch ${LOCKFILE}
  fi
 fi
fi
