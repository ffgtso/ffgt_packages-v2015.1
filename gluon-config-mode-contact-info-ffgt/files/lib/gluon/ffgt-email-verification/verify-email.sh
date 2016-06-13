#!/bin/sh

# Script to basically verify an email address; exits 0 on valid, 1 else.
# Supposed to be used in Lua scripts like local valid=os.execute("...")

if [ $# -ne 1 ]; then
 logger "Usage: $0 email"
 echo "Usage"
 exit 1
fi

EMAIL="$1"
IPVXPREFIX="`/lib/gluon/ffgt-geolocate/ipv5.sh`"
DATAFILE="/tmp/verify-$$.out"
VALID=0

if [ "Y$IPVXPREFIX" == "Y" -o "$IPVXPREFIX" == "ipv5." ]; then
 logger "$0: IPv5 not implemented."
 echo "IPv5"
 exit 1
fi

/usr/bin/wget -q -O ${DATAFILE} "http://setup.${IPVXPREFIX}4830.org/validate_email.php?email=${EMAIL}"
if [ -e ${DATAFILE} ]; then
 grep "Valid" <${DATAFILE} >/dev/null 2>&1
 if [ $? -eq 0 ]; then
  VALID=1
 fi
 rm ${DATAFILE}
fi

if [ $VALID -eq 1 ]; then
 echo "Valid"
 exit 0
else
 echo "Invalid"
 exit 1
fi
