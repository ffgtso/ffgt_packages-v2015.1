local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    [[Um deinen Knoten auf der Karte anzeigen zu können, benötigen
    wir seine Koordinaten. Hier hast du die Möglichkeit, diese zu
    hinterlegen.]])

  local o
  local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  if not lat then lat=0 end
  if not lon then lon=0 end
  if ((lat == 0) or (lat == 51)) and ((lon == 0) or (lon == 9)) then
    o = s:option(cbi.Value, "_zip", "Postleitzahl")
    o.default = "33333"
    o.rmempty = false

    lat = "51.908624626589585"
    lon = "8.380953669548035"
  end

  o = s:option(cbi.Value, "_latitude", "Breitengrad")
  o.default = uci:get_first("gluon-node-info", "location", "latitude")
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 53.873621"

  o = s:option(cbi.Value, "_longitude", "Längengrad")
  o.default = uci:get_first("gluon-node-info", "location", "longitude")
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 10.689901"

  local mystr = string.format("Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen, den Button zur Koordinatenanzeige klicken und dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://stats.guetersloh.freifunk.net/map/geomap.html?lat=%f&amp;lon=%f\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>", lat, lon)
  local s = form:section(cbi.SimpleSection, nil, mystr)
end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  if data._location and data._latitude ~= nil and data._longitude ~= nil then
    uci:set("gluon-node-info", sname, "latitude", data._latitude)
    uci:set("gluon-node-info", sname, "longitude", data._longitude)
  end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
