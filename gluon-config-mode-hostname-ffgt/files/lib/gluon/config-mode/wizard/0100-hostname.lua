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
  local mystrA = string.format("%s-%s-%s", zip, addr, mac)
  if mystrA ~= hostname then
    local o = s:option(cbi.DummyValue, "_defaulthostnameA", "Namensvorschlag 1")
    o.value = mystrA
  end
  mac = util.node_id()
  local mystrB = string.format("%s-freifunk-%s", zip,mac)
  if mystrB ~= hostname then
    local o = s:option(cbi.DummyValue, "_defaulthostnameB", "Namensvorschlag 2")
    o.value = mystrB
  end
end

function M.handle(data)
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local hostname = data._hostname
  hostname = hostname:gsub(" ","-")
  hostname = hostname:gsub("%.","-")
  hostname = hostname:gsub("%,","-")
  hostname = hostname:gsub("_","-")
  hostname = hostname:gsub("--","-")
  hostname = hostname:gsub("^ffgt-", zip .. "-")
  hostname = hostname:gsub("^ffrw-", zip .. "-")
  hostname = hostname:gsub("^freifunk-", zip .. "-")
  hostname = hostname:gsub("^gut-", zip .. "-")
  hostname = hostname:gsub("^tst-", zip .. "-")
  hostname = hostname:gsub("^rhwd-", zip .. "-")
  hostname = hostname:gsub("^muer-", zip .. "-")
  hostname = hostname:sub(1, 63)

  uci:set("system", uci:get_first("system", "system"), "hostname", hostname)
  uci:save("system")
  uci:commit("system")
end

return M
