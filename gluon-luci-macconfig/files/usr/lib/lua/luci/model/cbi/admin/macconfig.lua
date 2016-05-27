--[[
LuCI - Lua Configuration Interface

Copyright 2016 Kai 'wusel' Siering <wusel+src@uu.org>,
based on work of Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local uci = luci.model.uci.cursor()
local sysconfig = require 'gluon.sysconfig'
local util = require 'gluon.util'

local f = SimpleForm("macconfig", translate("MAC"))
f.template = "admin/expertmode"

local s
local o
local wan_mac       = util.generate_mac_2014_4(1, 0)
local wan_mac_fixed = util.generate_mac_2014_3(1, 0)

s = f:section(SimpleSection, nil, [[Falls die WAN-MAC-Adresse
  des Knotens z. B. in einer Firewall freigeschaltet werden mu&szlig;,
  aktiviere bitte die folgende Option. Wir werden dann versuchen,
  die WAN-MAC-Adresse auch in zuk&uuml;nftigen Firmwareversionen nicht
  zu &auml;ndern.]])

s = f:section(SimpleSection, nil, "WAN MAC normal: " .. wan_mac)
s = f:section(SimpleSection, nil, "WAN MAC fest: " .. wan_mac_fixed)


o = s:option(Flag, "static_mac", translate("WAN MAC needs white-listing"))
o.default = uci:get_first("gluon-node-info", "system", "wan_mac_static") and o.enabled or o.disabled
o.rmempty = false


function f.handle(self, state, data)
  if state == FORM_VALID then
    local sname = uci:get_first("gluon-node-info", "system")
    uci:set("gluon-node-info", sname, "wan_mac_static", data.static_mac)
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")
  end

  return true
end

return f
