local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local util = require 'gluon.util'

local M = {}

function M.section(form)
  local hostname = uci:get_first("system", "system", "hostname")
  local addr = uci:get_first("gluon-node-info", 'location', "addr")
  local city = uci:get_first("gluon-node-info", 'location', "city")
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local mac = string.sub(util.node_id(), 9)

  hostname = hostname:gsub("^ffgt%-", "")
  hostname = hostname:gsub("^ffrw%-", "")
  hostname = hostname:gsub("^freifunk%-", "")
  hostname = hostname:gsub("^gut%-", "")
  hostname = hostname:gsub("^tst%-", "")
  hostname = hostname:gsub("^rhwd%-", "")
  hostname = hostname:gsub("^muer%-", "")
  #hostname = hostname:gsub("^" .. zip .. "%-", "")
  hostname = hostname:gsub("^%d%d%d%d%d%-", "")
  hostname = hostname:gsub(" ","-")
  hostname = hostname:gsub("%p","-")
  hostname = hostname:gsub("_","-")
  hostname = hostname:gsub("%-%-","-")
  hostname = hostname:sub(1, 30)

  local s = form:section(cbi.SimpleSection, nil, [[Bitte gib' Deinem
  Knoten einen sprechenden Namen (z. B. Adresse, Bauwerk, Gesch&auml;ft).
  Es k&ouml;nnen nur Buchstaben, Zahlen und der Bindestrich verwendet
  werden, jenseits 30 Zeichen wird abgeschnitten. Dem Namen wird die
  PLZ des Aufstellstandortes vorangestellt, Prefixe sind also nicht
  notwendig.]])
  local optstr=string.format("Name dieses Knotens: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %s-", zip)
  local o = s:option(cbi.Value, "_hostname", optstr)
  o.value = hostname
  o.rmempty = false
  o.datatype = "hostname"

  local mystrA = string.format("%s-%s", addr, mac)
  local mystrB = string.format("%s-%s", city, mac)
  local mystrC = string.format("freifunk-%s", util.node_id())
  local hostnameEx = s:option(cbi.ListValue, "_defhostname", string.format("Namensbeispiele: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %s-", zip))
  hostnameEx:value("input", hostname)
  if mystrA ~= hostname then
    hostnameEx:value(mystrA, string.format("%s (Adresse)", mystrA))
  end
  if mystrB ~= hostname then
    hostnameEx:value(mystrB, string.format("%s (Ort)", mystrB))
  end
  if mystrC ~= hostname then
    hostnameEx:value(mystrC, string.format("%s (Gerätekennung)", mystrC))
  end
end

function M.handle(data)
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local hostname
  if data._defhostname ~= "input" then
      hostname = data._defhostname
  else
      hostname = data._hostname
  end
  hostname = hostname:gsub(" ","-")
  hostname = hostname:gsub("%p","-")
  hostname = hostname:gsub("_","-")
  hostname = hostname:gsub("%-%-","-")
  hostname = zip .. "-" .. hostname
  hostname = hostname:sub(1, 30)

  uci:set("system", uci:get_first("system", "system"), "hostname", hostname)
  uci:save("system")
  uci:commit("system")
end

return M
