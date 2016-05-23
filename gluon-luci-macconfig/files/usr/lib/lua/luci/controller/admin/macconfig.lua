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

module("luci.controller.admin.macconfig", package.seeall)

function index()
        entry({"admin", "macconfig"}, cbi("admin/macconfig"), _("MAC"), 20)
end
