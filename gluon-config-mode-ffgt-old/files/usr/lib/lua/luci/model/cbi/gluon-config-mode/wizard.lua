local configmode = require "luci.tools.gluon-config-mode"
local meshvpn_name = "mesh_vpn"
local uci = luci.model.uci.cursor()
local f, s, o

-- prepare fastd key as early as possible
configmode.setup_fastd_secret(meshvpn_name)

f = SimpleForm("wizard")
f.reset = false
f.template = "gluon-config-mode/cbi/wizard"
f.submit = "Fertig"

s = f:section(SimpleSection, nil, nil)

o = s:option(Value, "_hostname", "Name dieses Knotens (wird nur in der Karte verwendet)")
o.value = uci:get_first("system", "system", "hostname")
o.rmempty = false
o.datatype = "hostname"

s = f:section(SimpleSection, nil, [[Bitte nenne die Bandbreite, die Du für Deinen Freifunk-Knoten
an Deinem Internetzugang zum Teilen freigeben willst. (Jeweils rund die Hälfte Deiner Up-
und Downstream-Bandbreite sind normalerweise sinnvolle Werte. Also z. B. bei DSL mit 16 MBit/sec:
8000 kBit down und 500 kBit up.)]])

o = s:option(Value, "_limit_ingress", "Downstream (kbit/s)")
o.value = "8000"
o.rmempty = false
o.datatype = "integer"

o = s:option(Value, "_limit_egress", "Upstream (kbit/s)")
o.value = "500"
o.rmempty = false
o.datatype = "integer"

s = f:section(SimpleSection, nil, [[Um deinen Knoten auf der Karte anzeigen
zu können, benötigen wir seine Koordinaten. Hier hast du die Möglichkeit,
diese zu hinterlegen. Die einfachste Möglichkeit ist es derzeit, auf unsere
<a href="http://setup.guetersloh.freifunk.net/mapredir.html" target="_blank">Knotenkarte</a>
(neues Fenster) zu gehen, auf Deinen Aufstellort zu zoomen, dann
»Koordinaten beim nächsten Klick zeigen« anzuklicken und auf den
Aufstellort zu klicken. Die Koordinaten dann bitte getrennt in diese
beiden Felder kopieren.]])

o = s:option(Value, "_latitude", "Breitengrad")
o.default = uci:get_first("gluon-node-info", "location", "latitude")
o.rmempty = false
o.datatype = "float"
o.description = "z.B. 51.90643043887704"

o = s:option(Value, "_longitude", "Längengrad")
o.default = uci:get_first("gluon-node-info", "location", "longitude")
o.rmempty = false
o.datatype = "float"
o.description = "z.B. 8.378351926803589"

s = f:section(SimpleSection, nil, [[Hier kannst du einen
<em>öffentlichen</em> Hinweis hinterlegen um anderen Freifunkern zu
ermöglichen Kontakt mit dir aufzunehmen. Bitte beachte, dass dieser Hinweis
auch öffentlich im Internet, zusammen mit den Koordinaten deines Knotens,
einsehbar sein wird.]])

o = s:option(Value, "_contact", "Kontakt")
o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
o.rmempty = true
o.datatype = "string"
o.description = "z.B. E-Mail oder Telefonnummer"
o.maxlen = 140

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = false

    uci:set("autoupdater", "settings", "enabled", "1")
    uci:save("autoupdater")
    uci:commit("autoupdater")

    uci:set("gluon-simple-tc", meshvpn_name, "interface")
    uci:set("gluon-simple-tc", meshvpn_name, "enabled", "1")
    uci:set("gluon-simple-tc", meshvpn_name, "ifname", "mesh-vpn")

    if data._limit_ingress ~= nil then
      uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", data._limit_ingress)
    else
      uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", "8000")      
    end

    if data._limit_egress ~= nil then
      uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", data._limit_egress)
    else
      uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", "500")
    end

    uci:commit("gluon-simple-tc")

    uci:set("fastd", meshvpn_name, "enabled", "1")
    uci:save("fastd")
    uci:commit("fastd")

    uci:set("system", uci:get_first("system", "system"), "hostname", data._hostname)
    uci:save("system")
    uci:commit("system")

    local sname = uci:get_first("gluon-node-info", "location")
    uci:set("gluon-node-info", sname, "share_location", "1")
    if data._latitude ~= nil and data._longitude ~= nil then
      uci:set("gluon-node-info", sname, "latitude", data._latitude)
      uci:set("gluon-node-info", sname, "longitude", data._longitude)
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
