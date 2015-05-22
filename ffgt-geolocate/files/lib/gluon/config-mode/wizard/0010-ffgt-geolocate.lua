local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

-- FIXME! This belongs into a different ffgt-related config mode package!
-- This code sets some presets for our Firmwares.
local uci = luci.model.uci.cursor()
local secret = uci:get("fastd", "mesh_vpn", "secret")

if not secret or not secret:match("%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x") then
  local f = io.popen("fastd --generate-key --machine-readable", "r")
  local secret = f:read("*a")
  f:close()

  uci:set("fastd", "mesh_vpn", "secret", secret)
  uci:save("fastd")
  uci:commit("fastd")

  uci:set("autoupdater", "settings", "enabled", "1")
  uci:save("autoupdater")
  uci:commit("autoupdater")

  uci:set("fastd", "mesh_vpn", "enabled", "1")
  uci:save("fastd")
  uci:commit("fastd")

  uci:set("gluon-simple-tc", "mesh_vpn", "interface")
  uci:set("gluon-simple-tc", "mesh_vpn", "ifname", "mesh-vpn")
  uci:set("gluon-simple-tc", "mesh_vpn", "enabled", "0")
  uci:save("gluon-simple-tc")
  uci:commit("gluon-simple-tc")

  local sname = uci:get_first("gluon-node-info", "location")
  uci:set("gluon-node-info", sname, "share_location", "1")
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

-- If there's no location set, try to get something via callback, as we need this for
-- selecting the proper settings.
local lat = uci:get_first("gluon-node-info", 'location', "latitude")
local lon = uci:get_first("gluon-node-info", 'location', "longitude")
if not lat or not lon then
    os.execute('sh "/lib/gluon/ffgt-geolocate/senddata.sh"')
    os.execute('sleep 20')
end

local M = {}

function M.section(form)
    local lat = uci:get_first("gluon-node-info", 'location', "latitude")
    local lon = uci:get_first("gluon-node-info", 'location', "longitude")
    if not lat then lat=0 end
    if not lon then lon=0 end
    if ((lat == 0) or (lat == 51)) and ((lon == 0) or (lon == 9)) then
        local s = form:section(cbi.SimpleSection, nil,
        [[Es wurde versucht, den Knoten automatisch zu lokalisieren. Dies schlug leider fehl.
        Ist der Knoten über die gelben(!) Ports mit dem Internet-Router verbunden?]])
    else
        local addr = uci:get_first("gluon-node-info", 'location', "addr")
        local city = uci:get_first("gluon-node-info", 'location', "city")
        local zip = uci:get_first("gluon-node-info", 'location', "zip")
        local unlocode = uci:get_first("gluon-node-info", "location", "locode")
	    local community= uci:get('siteselect', unlocode, 'sitename')
        local mystr = string.format("Lokalisierung des Knotens erfolgreich; bitte Daten &uuml;berpr&uuml;fen:<br></br><b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, community)
        local s = form:section(cbi.SimpleSection, nil, mystr)
    end
end

function M.handle(data)
  return
end

return M
