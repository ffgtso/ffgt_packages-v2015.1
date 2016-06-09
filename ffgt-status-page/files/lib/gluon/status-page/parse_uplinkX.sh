#!/bin/sh
# Usage: $0 uplink0

if [ $# -ne 1 ]; then
  exit 0
fi
iwinfo "$1" info | awk '/ESSID:/ {essid=substr($0, index($0, "ESSID:")+7); dataok=1;} /Channel:/ {chan=$4;} /Link Quality/ {lnkqul=$NF;} /Bit Rate:/ {rate=substr($0, index($0, "Bit Rate")+10);} END {if(dataok==1) {printf("%s, Ch. %s, Link %s, %s", essid, chan, lnkqul, rate);}}'
