--[[
LuCI - Lua Configuration Interface

Copyright 2015 Kai 'wusel' Siering <wusel+src@uu.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local uci = luci.model.uci.cursor()

local hostname, addr, locode, city
local s
local sites = {}

local f = SimpleForm("site-select", "site.conf-Auswahl")
f.template = "admin/expertmode"

local s
local o
local uplink = "wired"

s = f:section(SimpleSection, nil, [[Hier kann sie site.conf ausgewählt werden ...]])

uci:foreach('siteselect', 'site',
  function(s)
    table.insert(sites, s['.name'])
   end
)

local o = s:option(cbi.ListValue, "community", "Community")
o.rmempty = false
o.optional = false




s = f:section(SimpleSection, nil, [[Bitte mit "Weiter" weitergehen.]])

function f.handle(self, state, data)
  return true
end

return f
