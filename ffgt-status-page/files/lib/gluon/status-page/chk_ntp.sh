#!/bin/sh

timeserver="`uci get system.ntp.server | sed -e 's/ / -p /g'`"

/usr/sbin/ntpd -w -p ${timeserver} 2>/tmp/ntp.chk &
sleep 5
ps w | grep -v grep | grep "ntpd -w -p" | awk '/ntp/ {printf("kill %s\n", $1);}' | /bin/sh
awk </tmp/ntp.chk 'BEGIN{offset="ntp error";} /ntpd: reply from/ {offset=$5; gsub("offset:", "", offset); offset=offset+0.0; warnstr=""; if (offset<0) offset=offset*-1; if (offset > 5.0) warnstr=" (NTP SEEMS TO HAVE ISSUES)"; offset=sprintf("%.1f sec%s", offset, warnstr);} END{print offset;}'
