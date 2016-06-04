#!/bin/sh

echo "" > /etc/config/siteselect

/bin/ls -1 /lib/gluon/site-select/ | while read FILE
do
site_name="$(cat /lib/gluon/site-select/"$FILE" | grep "site_name" | sed "s/site_name =//; s/,//")"
#site_code="$(cat "$GLUON_SITEDIR"/site-select/"$FILE" | grep "site_code" | sed "s/site_code =//; s/,//")"
# We use an external code (the UN/LOCODE (http://www.unece.org/cefact/locode/welcome.html) to select
# which site.conf should be used where ...
site_code="$(basename "$FILE" .conf)"

echo "config site '"$site_code"'" >> /etc/config/siteselect
echo "    option path '/lib/gluon/site-select/"$FILE"'" >> /etc/config/siteselect
echo "    option sitename "$site_name"" >> /etc/config/siteselect
echo "" >> /etc/config/siteselect

done
