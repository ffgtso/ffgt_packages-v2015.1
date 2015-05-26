local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local util = require 'gluon.util'

local M = {}

function M.section(form)
  local hostname = uci:get_first("system", "system", "hostname")
  local s = form:section(cbi.SimpleSection, nil, nil)
  local o = s:option(cbi.Value, "_hostname", "Name dieses Knotens")
  o.value = hostname
  o.rmempty = false
  o.datatype = "hostname"

  local addr = uci:get_first("gluon-node-info", 'location', "addr")
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local mac = string.sub(util.node_id(), 9)
  local mystr = string.format("%s-%s-%s", zip, addr, mac)
  if mystr ~= hostname then
    local o = s:option(cbi.DummyValue, "_defaulthostname", "Namensvorschlag")
    o.value = mystr
  end
end

function M.handle(data)
  uci:set("system", uci:get_first("system", "system"), "hostname", data._hostname)
  uci:save("system")
  uci:commit("system")
end

return M
