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

