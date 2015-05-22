local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    [[Um deinen Knoten auf der Karte anzeigen zu können, benötigen
    wir seine Koordinaten. Hier hast du die Möglichkeit, diese zu
    hinterlegen.]])

  local o

  o = s:option(cbi.Flag, "_location", "Knoten auf der Karte anzeigen")
  o.default = uci:get_first("gluon-node-info", "location", "share_location", o.disabled)
  o.rmempty = false

  o = s:option(cbi.Value, "_latitude", "Breitengrad")
  o.default = uci:get_first("gluon-node-info", "location", "latitude")
  o:depends("_location", "1")
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 53.873621"

  o = s:option(cbi.Value, "_longitude", "Längengrad")
  o.default = uci:get_first("gluon-node-info", "location", "longitude")
  o:depends("_location", "1")
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 10.689901"

  local mylat = uci:get_first("gluon-node-info", "location", "latitude")
  local mylon = uci:get_first("gluon-node-info", "location", "longitude")
  local mystr = string.format("Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen, den Button zur Koordinatenanzeige klicken und dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://stats.guetersloh.freifunk.net/map/geomap.html?lat=%f&amp;lon=%f\" width=\"100%\" height=\"700\">Unsere Knotenkarte</iframe></p>", mylat, mylon)

  local s = form:section(cbi.SimpleSection, nil, mystr)
end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  if data._location and data._latitude ~= nil and data._longitude ~= nil then
    uci:set("gluon-node-info", sname, "latitude", data._latitude)
    uci:set("gluon-node-info", sname, "longitude", data._longitude)
  end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
