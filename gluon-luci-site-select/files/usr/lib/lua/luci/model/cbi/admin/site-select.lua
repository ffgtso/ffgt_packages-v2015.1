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
local cbi = require "luci.cbi"
local hostname, addr, locode, city
local s
local sites = {}

local f = SimpleForm("site-select", "site.conf-Auswahl")
f.template = "admin/expertmode"

local s
local o
local uplink = "wired"
local sitename
local sname
local siteselect

s = f:section(SimpleSection, nil, [[
  Hier kann sie site.conf ausgewählt werden ... <strong>Achtung:</strong> Diese Einstellungen
  ver&auml;ndern die Kernfunktion des Freifunk-Knotens. Normalerweise wird die passende Region &uuml;ber
  die Koordinaten automatisch ausgew&auml;hlt. Nur für den Fall, daß dieses fehlschlagen sollte oder spezielle
  Einstellungen (andere als die normalen Kan&auml;le im Falle von gr&ouml;&szlig;eren Installationen) beni&ouml;tigt
  werden, diese Daten &auml;ndern! <strong>Auswahl der falschen Region kann zum totalen Ausfall des Knotens
  f&uuml;hren!</strong>
]])

local o = s:option(cbi.ListValue, "community", "Region")
sname = uci:get_first("gluon-node-info", "location")
siteselect = uci:get("gluon-node-info", sname, "siteselect")

if siteselect then
  sitename=uci:get("siteselect", siteselect, "sitename") .. ' *'
  o:value(siteselect, sitename)
end

uci:foreach('siteselect', 'site',
  function(s)
    if s['.name'] ~= siteselect then
      sitename=uci:get("siteselect", s['.name'], "sitename")
      o:value(s['.name'], sitename)
    end
  end
)
o.rmempty = false
o.optional = false

function f.handle(self, state, data)
   if state == FORM_VALID then
    local sname = uci:get_first("gluon-node-info", "location")
    local siteselect = uci:get("gluon-node-info", sname, "siteselect")

    if not siteselect == data.community then
      uci:set("gluon-node-info", sname, "siteselect", data.community)
      uci:save("gluon-node-info")
      uci:commit("gluon-node-info")
      -- Copy the proper according to loc site.conf in place.
      os.execute("echo 'Updating system-wide site.conf'")
      local srcfile=uci:get("siteselect", data.community, "path")
      os.execute(string.format("echo src=%s com=%s", srcfile, data.community))
      os.execute(string.format("/bin/cp %s /lib/gluon/site.conf", srcfile))
      os.execute('/lib/gluon/site-upgrade &')
    end
  end

 return true
end

return f
