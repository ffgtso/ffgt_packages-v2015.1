local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    [[Bitte nenne die Bandbreite, die Du f&uuml;r Deinen Freifunk-Knoten
    an Deinem Internetzugang zum Teilen freigeben willst. Der Wert 0 schaltet
    die Begrenzung aus (z. B. weil Du Deinen Anschlu&szlig; komplett freigeben
    willst oder aber anders die Bandbreite kontrollierst).]])

  local o

--  o = s:option(cbi.Flag, "_meshvpn", "Internetverbindung nutzen (Mesh-VPN)")
--  o.default = uci:get_bool("fastd", "mesh_vpn", "enabled") and o.enabled or o.disabled
--  o.rmempty = false

--  o = s:option(cbi.Flag, "_limit_enabled", "Zu teilende Bandbreite begrenzen")
--  o:depends("_meshvpn", "1")
--  o.default = uci:get_bool("gluon-simple-tc", "mesh_vpn", "enabled") and o.enabled or o.disabled
--  o.rmempty = false

  o = s:option(cbi.Value, "_limit_ingress", "Downstream (kbit/s)")
--  o:depends("_limit_enabled", "1")
--  o.value = uci:get("gluon-simple-tc", "mesh_vpn", "limit_ingress")
  o.value = "0"
  o.rmempty = false
  o.datatype = "integer"

  o = s:option(cbi.Value, "_limit_egress", "Upstream (kbit/s)")
--  o:depends("_limit_enabled", "1")
--  o.value = uci:get("gluon-simple-tc", "mesh_vpn", "limit_egress")
  o.value = "0"
  o.rmempty = false
  o.datatype = "integer"
end

function M.handle(data)
--  uci:set("fastd", "mesh_vpn", "enabled", data._meshvpn)
--  uci:save("fastd")
--  uci:commit("fastd")

  -- checks for nil needed due to o:depends(...)
--  if data._limit_enabled ~= nil then
--    uci:set("gluon-simple-tc", "mesh_vpn", "interface")
--    uci:set("gluon-simple-tc", "mesh_vpn", "enabled", data._limit_enabled)
--    uci:set("gluon-simple-tc", "mesh_vpn", "ifname", "mesh-vpn")

    if data._limit_ingress ~= nil then
      uci:set("gluon-simple-tc", "mesh_vpn", "limit_ingress", data._limit_ingress)
    end

    if data._limit_egress ~= nil then
      uci:set("gluon-simple-tc", "mesh_vpn", "limit_egress", data._limit_egress)
    end

    if data._limit_ingress ~= nil and data._limit_egress ~= nil and data._limit_egress + 0 > 0 and data._limit_ingress + 0 > 0 then
      uci:set("gluon-simple-tc", meshvpn_name, "enabled", "1")
    end

    uci:commit("gluon-simple-tc")

    uci:set("fastd", "mesh_vpn", "enabled", "1")
    uci:save("fastd")
    uci:commit("fastd")
--  end
end

return M
