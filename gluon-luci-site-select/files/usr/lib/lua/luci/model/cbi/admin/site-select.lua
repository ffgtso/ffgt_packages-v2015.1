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

function f.handle(self, state, data)
   if state == FORM_VALID then
    local sname = uci:get_first("gluon-node-info", "location")
    local siteselect = uci:get_first("gluon-node-info", sname, "siteselect")

    if not siteselect == data.community then
      uci:set("gluon-node-info", sname, "siteselect", data.community)
      uci:save("gluon-node-info")
      uci:commit("gluon-node-info")
      -- Copy the proper according to loc site.conf in place.
      os.execute("echo 'Updating system-wide site.conf'")
      local cmdline=string.format('/sbin/uci get siteselect.%s.path', data.community)
      local srcfile=string.gsub(sys.exec(cmdline), "\n", "")
      os.execute(string.format("echo src=%s com=%s", srcfile, data.community))
      os.execute(string.format("/bin/cp %s /lib/gluon/site.conf", srcfile))
      os.execute('/lib/gluon/site-upgrade &')
    end
  end

 return true
end

return f
