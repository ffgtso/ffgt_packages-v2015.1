local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local lat = uci:get_first("gluon-node-info", "location", "latitude")
  local lon = uci:get_first("gluon-node-info", "location", "longitude")
  local addr = uci:get_first("gluon-node-info", 'location', "addr")
  local city = uci:get_first("gluon-node-info", 'location', "city")
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local unlocode = uci:get_first("gluon-node-info", "location", "locode")
  local community = uci:get_first('siteselect', unlocode, 'sitename') or unlocode
  local mystr = string.format("Lokalisierung des Knotens erfolgreich; bitte Daten &uuml;berpr&uuml;fen:<br></br><b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, community)
  local s = form:section(cbi.SimpleSection, nil, mystr)

  local s = form:section(cbi.SimpleSection, nil,
    [[Um deinen Knoten auf der Karte anzeigen zu können, benötigen
    wir Deine Zustimmung. Es wäre sch&ouml;n, wenn Du uns diese hier
    geben w&uuml;rdest.]])

  local o
  -- FXIME! This is the totally wrong place, but in geoloc/0200-geo-location.lua
  -- lua/luci fail due to what seems to be a caching issue. I hate to need to work around
  -- stupidity :(
  if not unlocode or (lat == "51" and lon == "9") then
    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard-pre"))
  end

  o = s:option(cbi.Flag, "_location", "Knoten auf der Karte anzeigen")
  o.default = uci:get_first("gluon-node-info", "location", "share_location", o.disabled)
  o.rmempty = false
  o.optional = false

  o = s:option(cbi.DummyValue, "_latitude", "Breitengrad")
  o.default = uci:get_first("gluon-node-info", "location", "latitude")
  o:depends("_location", "1")
  --o.rmempty = false
  --o.datatype = "float"
  --o.description = "z.B. 53.873621"

  o = s:option(cbi.DummyValue, "_longitude", "Längengrad")
  o.default = uci:get_first("gluon-node-info", "location", "longitude")
  o:depends("_location", "1")
  --o.rmempty = false
  --o.datatype = "float"
  --o.description = "z.B. 10.689901"

  --local mylat = uci:get_first("gluon-node-info", "location", "latitude")
  --local mylon = uci:get_first("gluon-node-info", "location", "longitude")
  --local mystr = string.format("Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen, den Button zur Koordinatenanzeige klicken und dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://stats.guetersloh.freifunk.net/map/geomap.html?lat=%f&amp;lon=%f\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>", mylat, mylon)
  --local s = form:section(cbi.SimpleSection, nil, mystr)
end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  --if data._location and data._latitude ~= nil and data._longitude ~= nil then
  --  uci:set("gluon-node-info", sname, "latitude", data._latitude)
  --  uci:set("gluon-node-info", sname, "longitude", data._longitude)
  --end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
