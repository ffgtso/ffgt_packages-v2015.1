local configmode = require "luci.tools.gluon-config-mode"
local meshvpn_name = "mesh_vpn"
local uci = luci.model.uci.cursor()
local f, s, o, tmps

-- prepare fastd key as early as possible
configmode.setup_fastd_secret(meshvpn_name)

f = SimpleForm("wizard")
f.reset = false
f.template = "gluon-config-mode/cbi/wizard"
f.submit = "Fertig"

s = f:section(SimpleSection, nil, nil)

if uci:get_bool("autoupdater", "settings", "enabled")  then
  s = f:section(SimpleSection, nil, [[Dieser Knoten aktualisiert seine Firmware <b>automatisch</b>,
  sobald eine neue Version vorliegt. Falls Du dies nicht möchtest,
  kannst Du die Funktion im <i>Expertmode</i> deaktivieren.]])
else
  s = f:section(SimpleSection, nil, [[Dieser Knoten aktualisiert seine Firmware <b>nicht automatisch</b>.
  Bitte reaktiviere diese Funktion im <i>Expertmode</i>.]])
end

o = s:option(Value, "_hostname", "Name dieses Knotens")
o.value = uci:get_first("system", "system", "hostname")
o.rmempty = false
o.datatype = "hostname"

-- o = s:option(Flag, "_autoupdate", "Firmware automatisch aktualisieren")
-- o.default = uci:get_bool("autoupdater", "settings", "enabled") and o.enabled or o.disabled
-- o.rmempty = false

s = f:section(SimpleSection, nil, [[Bitte nenne die Bandbreite, die Du f&uuml;r Deinen Freifunk-Knoten
an Deinem Internetzugang zum Teilen freigeben willst. Der Wert 0 schaltet die Begrenzung aus
(z. B. weil Du Deinen Anschlu&szlig; komplett freigeben willst oder aber anders die Bandbreite
kontrollierst).]])

-- o = s:option(Flag, "_meshvpn", "Mesh-VPN aktivieren")
-- o.default = uci:get_bool("fastd", meshvpn_name, "enabled") and o.enabled or o.disabled
-- o.rmempty = false

-- o = s:option(Flag, "_limit_enabled", "Zu teilende Bandbreite begrenzen")
-- o:depends("_meshvpn", "1")
-- o.default = uci:get_bool("gluon-simple-tc", meshvpn_name, "enabled") and o.enabled or o.disabled
-- o.rmempty = false

o = s:option(Value, "_limit_ingress", "Downstream (kbit/s)")
-- o:depends("_limit_enabled", "1")
o.value = "8000"
-- uci:get("gluon-simple-tc", meshvpn_name, "limit_ingress")
o.rmempty = false
o.datatype = "integer"

o = s:option(Value, "_limit_egress", "Upstream (kbit/s)")
-- o:depends("_limit_enabled", "1")
o.value = "500"
-- uci:get("gluon-simple-tc", meshvpn_name, "limit_egress")
o.rmempty = false
o.datatype = "integer"

s = f:section(SimpleSection, nil, [[Hier kannst du einen
<em>&ouml;ffentlichen</em> Hinweis hinterlegen, um anderen Freifunkern zu
erm&ouml;glichen, Kontakt mit dir aufzunehmen. Bitte beachte, dass dieser Hinweis
auch &ouml;ffentlich im Internet, ggf. zusammen mit den Koordinaten deines Knotens,
einsehbar sein wird.]])

o = s:option(Value, "_contact", "Kontakt")
o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
o.rmempty = true
o.datatype = "string"
o.description = "z.B. E-Mail oder Telefonnummer"
o.maxlen = 140

s = f:section(SimpleSection, nil, [[Um das Netz besser planen zu
k&ouml;nnen, ben&ouml;tigen wir die Koordinaten Deines Knotens, die Du hier
hinterlegen kannst. Die einfachste M&ouml;glichkeit, an genaue Daten
zu kommen, ist es derzeit, auf unsere
<a href="http://setup.guetersloh.freifunk.net/mapredir.html" target="_blank">Knotenkarte</a>
(neues Fenster oder siehe unten) zu gehen, auf Deinen Aufstellort zu scrollen, dann
&uuml;ber »Koordinaten beim n&auml;chsten Klick zeigen« die Koordinaten zu
sehen; bitte die zwei Werte getrennt in jeweils eines der beiden
Felder kopieren.]])

o = s:option(Value, "_latitude", "Breitengrad")
o.default = uci:get_first("gluon-node-info", "location", "latitude")
o:depends("_location", "1")
o.rmempty = false
o.datatype = "float"
o.description = "z.B. 51.90643043887704"

o = s:option(Value, "_longitude", "L&auml;ngengrad")
o.default = uci:get_first("gluon-node-info", "location", "longitude")
o:depends("_location", "1")
o.rmempty = false
o.datatype = "float"
o.description = "z.B. 8.378351926803589"

o = s:option(Flag, "_location", "Knoten auf der <a href=\"http://guetersloh.freifunk.net/map/geomap.html\">Karte</a> anzeigen?")
-- o.default = uci:get_first("gluon-node-info", "location", "share_location", o.enabled)
o.default = "1"
o.rmempty = false

-- o = s:option(Flag, "_ismobile", "Mobiler Knoten (automatisches Update der Koordinaten beim Start)?")
-- o.default = uci:get_first("gluon-node-info", "location", "is_mobile", o.enabled)
-- o.rmempty = false

s = f:section(SimpleSection, nil, [[Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat: <p><iframe src="http://guetersloh.freifunk.net/map/geomap.html" width="100%" height="700">Unsere Knotenkarte</iframe></p>]])
-- s:depends(data._location, "1")

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = false

    uci:set("gluon-simple-tc", meshvpn_name, "interface")
--    uci:set("gluon-simple-tc", meshvpn_name, "enabled", "1")
    uci:set("gluon-simple-tc", meshvpn_name, "ifname", "mesh-vpn")

    -- checks for nil needed due to o:depends(...)
--    if data._limit_enabled ~= nil then
--      uci:set("gluon-simple-tc", meshvpn_name, "interface")
--      uci:set("gluon-simple-tc", meshvpn_name, "enabled", data._limit_enabled)
--      uci:set("gluon-simple-tc", meshvpn_name, "ifname", "mesh-vpn")

      if data._limit_ingress ~= nil then
        uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", data._limit_ingress)
--      else
--        uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", "8000")
      end

      if data._limit_egress ~= nil then
        uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", data._limit_egress)
--      else
--        uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", "500")
      end

      if data._limit_ingress ~= nil and data._limit_egress ~= nil and data._limit_egress + 0 > 0 and data._limit_ingress + 0 > 0 then
        uci:set("gluon-simple-tc", meshvpn_name, "enabled", "1")
      end

      uci:commit("gluon-simple-tc")
--    end

    uci:set("fastd", meshvpn_name, "enabled", "1")
    uci:save("fastd")
    uci:commit("fastd")

    local hostname = data._hostname
    hostname = hostname:gsub(" ","_")
--    hostname = hostname:gsub("%.","_")
    hostname = hostname:gsub("%,","_")
    hostname = hostname:sub(1, 63)

    uci:set("system", uci:get_first("system", "system"), "hostname", hostname)
    uci:save("system")
    uci:commit("system")

    local sname = uci:get_first("gluon-node-info", "location")
    if data._latitude ~= nil and data._longitude ~= nil then
      uci:set("gluon-node-info", sname, "latitude", data._latitude)
      uci:set("gluon-node-info", sname, "longitude", data._longitude)
    end
    uci:set("gluon-node-info", sname, "share_location", data._location)
    if data._ismobile ~= nil then                                               
      uci:set("gluon-node-info", sname, "is_mobile", data._ismobile)            
    else                                                                        
      uci:set("gluon-node-info", sname, "is_mobile", "0")                       
    end                                                                         

    if data._contact ~= nil then
      uci:set("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact", data._contact)
    else
      uci:delete("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact")
    end
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")

    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode", "reboot"))
  end

  return true
end

return f
