BEGIN {
 for (i = 0; i <= 255; i++) {
  ord[sprintf("%c", i)] = i
 }
 printf("http://setup.%s4830.org/geoloc.php?node=%s", ipv4prefix, escape(mac));
 numwifi=0;
}
function escape(str, c, len, res) {
 len = length(str)
 res = ""
 for (i = 1; i <= len; i++) {
  c = substr(str, i, 1);
  if (c ~ /[0-9A-Za-z]/) res = res c
  else res = res "%" sprintf("%02X", ord[c])
 }
 return res
}

/^BSS/ {numwifi++; BSS[numwifi]=$2; gsub(":", "-", BSS[numwifi]) gsub("\(on", "", BSS[numwifi]);}
/signal:/ {sig[numwifi]=$2;}
/SSID:/ {
 SSID[numwifi]=substr($0, index("SSID", $0)+8);
}
/DS Parameter set:/ {HT[numwifi]=$NF;}
/primary channel:/ {HT[numwifi]=$NF;}
/secondary channel offset:/ {HT[numwifi]=sprintf("%s,%s", HT[numwifi], $NF=="secondary"?"none":$NF);}
END {
 for(j=1; j<=numwifi; j++) 
     printf("&wifi[]=mac:%s%%7Cssid:%s%%7Css:%s%%7Cchan:%s", BSS[j], escape(SSID[j]), sig[j], HT[j]);
}
