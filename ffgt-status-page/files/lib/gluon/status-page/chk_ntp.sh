#!/bin/sh

timeserver="`uci get system.ntp.server | sed -e 's/ / -p /g'`"

/usr/sbin/ntpd -w -p ${timeserver} 2>/tmp/ntp.chk &
sleep 5
ps w | grep -v grep | grep "ntpd -w -p" | awk '/ntp/ {printf("kill %s\n", $1);}' | /bin/sh
awk </tmp/ntp.chk 'BEGIN{offset="ntp error"} /ntpd: reply from/ {offset=$5; gsub("offset:", "", offset); offset=sprintf("%s sec", offset);} END{print offset;}'
