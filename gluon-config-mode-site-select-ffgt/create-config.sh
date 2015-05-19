#!/bin/sh

echo "" > "$DIR"/etc/config/siteselect

dir -1 "$GLUON_SITEDIR"/extra/ | while read FILE
do
site_name="$(cat "$GLUON_SITEDIR"/extra/"$FILE" | grep "site_name" | sed "s/site_name =//; s/,//")"
site_code="$(cat "$GLUON_SITEDIR"/extra/"$FILE" | grep "site_code" | sed "s/site_code =//; s/,//")"

echo "config site"$site_code"" >> "$DIR"/etc/config/siteselect
echo "    option path '/lib/gluon/site-select/"$FILE"'" >> "$DIR"/etc/config/siteselect
echo "    option sitename"$site_name"" >> "$DIR"/etc/config/siteselect
echo "" >> "$DIR"/etc/config/siteselect

done