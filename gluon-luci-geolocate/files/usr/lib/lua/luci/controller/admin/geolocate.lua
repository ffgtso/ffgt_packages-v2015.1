--[[
LuCI - Lua Configuration Interface

Copyright 2015 Kai 'wusel' Siering <wusel+src@uu.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.geolocate", package.seeall)

function index()
        entry({"admin", "geolocate"}, cbi("admin/geolocate"), _("Geo-Lokalisiering"), 20)
end

