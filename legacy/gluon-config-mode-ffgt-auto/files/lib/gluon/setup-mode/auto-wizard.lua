#!/usr/bin/lua

local luci = require "luci"
local io = require "io"
local configmode = require "luci.tools.gluon-config-mode"
local meshvpn_name = "mesh_vpn"
local sys = require("luci.sys")
local system, model = luci.sys.sysinfo()
local uci = luci.model.uci.cursor()

-- prepare fastd key as early as possible
configmode.setup_fastd_secret(meshvpn_name)

local stat = false
local hostname

uci:set("autoupdater", "settings", "enabled", "1")
uci:save("autoupdater")
uci:commit("autoupdater")

uci:set("gluon-simple-tc", meshvpn_name, "interface")
uci:set("gluon-simple-tc", meshvpn_name, "enabled", "1")
uci:set("gluon-simple-tc", meshvpn_name, "ifname", "mesh-vpn")
uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", "16000")      
uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", "1000")
uci:save("gluon-simple-tc")
uci:commit("gluon-simple-tc")

uci:set("fastd", meshvpn_name, "enabled", "1")
uci:save("fastd")
uci:commit("fastd")

local sname = uci:get_first("gluon-node-info", "location")
uci:set("gluon-node-info", sname, "share_location", "1")
uci:save("gluon-node-info")
uci:commit("gluon-node-info")

uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", "1")
uci:save("gluon-setup-mode")
uci:commit("gluon-setup-mode")

-- Sleep a little so the browser can fetch everything required to
-- display the reboot page, then reboot the device.
nixio.nanosleep(2)

-- Run reboot with popen so it gets its own std filehandles.
io.popen("reboot")

-- Prevent any further execution in this child.
os.exit()
