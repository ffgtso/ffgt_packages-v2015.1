#!/bin/sh

# Setup once at runtime ...
# ... after at least 5 minutes of uptime have passed:
uptime=`awk </proc/uptime 'BEGIN{uptime=0;} {uptime=sprintf("%d", $1);} END{print uptime;}'`
if [ $uptime -lt 300 ]; then
  echo "Waiting to pass 300 seconds of uptime for stabilizing."
  exit 0
fi

if [ ! -e /tmp/airtime.in ]; then
  echo "DEV2G=\"\""  > /tmp/airtime.in
  echo "DEV5G=\"\"" >> /tmp/airtime.in

  if [ ! -e /tmp/client0.info ]; then
    iw dev client0 info >/tmp/client0.info 2>/dev/null
  fi

  if [ ! -e /tmp/client1.info ]; then
    iw dev client1 info >/tmp/client1.info 2>/dev/null
  fi

  awk </tmp/client0.info '/^Interface/ {intf=$2;} /channel/ {ghz=$3; ghz=substr(ghz, 2, 1); printf("DEV%sG=%s\n", ghz, intf);}' >>/tmp/airtime.in
  awk </tmp/client1.info '/^Interface/ {intf=$2;} /channel/ {ghz=$3; ghz=substr(ghz, 2, 1); printf("DEV%sG=%s\n", ghz, intf);}' >>/tmp/airtime.in
  cat /tmp/client*.info | awk '/^Interface/ {intf=$2;} /channel/ {ghz=$3; ghz=substr(ghz, 2, 1); if(ghz=="2") {gsub("client", "radio", intf); printf("%s", intf);}}' >>/tmp/radio2G
  cat /tmp/client*.info | awk '/^Interface/ {intf=$2;} /channel/ {ghz=$3; ghz=substr(ghz, 2, 1); if(ghz=="5") {gsub("client", "radio", intf); printf("%s", intf);}}' >>/tmp/radio5G
fi

source /tmp/airtime.in

#echo $DEV2G $DEV5G

if [ "X$DEV2G" != "X" ]; then
  iw dev $DEV2G survey dump > /tmp/24dump
  if [ $? -eq 0 ]; then
    cat /tmp/24dump | sed '/Survey/,/\[in use\]/d'  > /tmp/24reduced
    ACT_CUR=$(ACTIVE=$(cat /tmp/24reduced | grep "active time:"); set ${ACTIVE:-0 0 0 0 0}; echo -e "${4}")
    BUS_CUR=$(BUSY=$(cat /tmp/24reduced | grep "busy time:"); set ${BUSY:-0 0 0 0 0}; echo -e "${4}")
    echo $ACT_CUR > /tmp/act2
    echo $BUS_CUR > /tmp/bus2
  fi
fi

if [ "X$DEV5G" != "X" ]; then
  iw dev $DEV5G survey dump > /tmp/5dump
  if [ $? -eq 0 ]; then
    cat /tmp/5dump | sed '/Survey/,/\[in use\]/d'  > /tmp/5reduced
    ACT_CUR=$(ACTIVE=$(cat /tmp/5reduced | grep "active time:"); set ${ACTIVE:-0 0 0 0 0}; echo -e "${4}")
    BUS_CUR=$(BUSY=$(cat /tmp/5reduced | grep "busy time:"); set ${BUSY:-0 0 0 0 0}; echo -e "${4}")
    echo $ACT_CUR > /tmp/act5
    echo $BUS_CUR > /tmp/bus5
  fi
fi
