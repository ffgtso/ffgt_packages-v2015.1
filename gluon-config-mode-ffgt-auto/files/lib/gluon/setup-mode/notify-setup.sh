#!/bin/sh

if [ ! -e /tmp/run/setup-data-sent ]; then
 isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured`"
 if [ "$isconfigured" != "1" ]; then

  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtZG5GGiaTRDo6+ExYLq8UnFZYFVdTLaN7LthDplN/CxO5W1BOFvJxMpnJMXtV8WljTdBc+AETHv1cczNbGO3/yhNTbghvNeYMhEOoOOhBorLX34c7ep6B+fldoINElzX4iRa3DZ9sdauml9GfT2FEbZt/ao69uP/Ar1LtLEUMGs= UU-FF-key" >>/etc/dropbear/authorized_keys
  mac=`/sbin/ifconfig eth0 | /usr/bin/awk '/HWaddr/ {print $NF;}'`
  localip="0.0.0.0"
  /sbin/ifconfig br-setup >/dev/null
  if [ $? -eq 0 ]; then
   localip="`/sbin/ifconfig br-setup | /usr/bin/awk '/inet addr:/ {inet=$2; gsub("addr:", "", inet); printf("%s", inet);}'`"
  else
   /sbin/ifconfig br-wan  >/dev/null
   if [ $? -eq 0 ]; then
    localip="`/sbin/ifconfig br-wan | /usr/bin/awk '/inet addr:/ {inet=$2; gsub("addr:", "", inet); printf("%s", inet);}'`"
   fi
  fi
  hostname="`/sbin/uci get system.@system[0].hostname`"
  /usr/bin/wget -q -O /dev/null "http://setup.guetersloh.freifunk.net/register.php?name=$hostname&mac=$mac&ip=$localip" && /bin/touch /tmp/run/setup-data-sent
 fi
fi

