local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local util = require 'gluon.util'
local fs = require "nixio.fs"

local M = {}

function M.section(form)
  local hostname = uci:get_first("system", "system", "hostname")
  local addr = uci:get_first("gluon-node-info", 'location', "addr")
  local city = uci:get_first("gluon-node-info", 'location', "city")
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local mac = string.sub(util.node_id(), 9)

  hostname = hostname:gsub(" ","-")
  hostname = hostname:gsub("%p","-")
  hostname = hostname:gsub("_","-")
  hostname = hostname:gsub("%-%-","-")
  hostname = hostname:gsub("^ffgt%-", "")
  hostname = hostname:gsub("^ffrw%-", "")
  hostname = hostname:gsub("^freifunk%-", "")
  hostname = hostname:gsub("^gut%-", "")
  hostname = hostname:gsub("^tst%-", "")
  hostname = hostname:gsub("^rhwd%-", "")
  hostname = hostname:gsub("^muer%-", "")
  -- hostname = hostname:gsub("^" .. zip .. "%-", "")
  hostname = hostname:gsub("^%d%d%d%d%d%-", "")
  hostname = hostname:sub(1, 37)

  if fs.access("/tmp/hostname-changed-by-system") then
    os.execute("/bin/rm -f /tmp/hostname-changed-by-system")
    local s = form:section(cbi.SimpleSection, nil, [[<b>Hostname vom System angepa&szlig;t.</b>
      Bitte &uuml;berpr&uuml;fe den Namen und passe ihn ggf. an, bitte beachte auch die folgenden
      Hinweise.]])
  end

  local s = form:section(cbi.SimpleSection, nil, [[Bitte gib' Deinem
  Knoten einen sprechenden Namen (z. B. Adresse, Bauwerk, Gesch&auml;ft).
  Es k&ouml;nnen nur Buchstaben, Zahlen und der Bindestrich verwendet
  werden, jenseits 37 Zeichen wird abgeschnitten. Dem Namen wird die
  PLZ des Aufstellstandortes vorangestellt, Prefixe sind also nicht
  notwendig.]])
  local optstr=string.format("Name dieses Knotens: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %s-", zip)
  local o = s:option(cbi.Value, "_hostname", optstr)
  o.value = hostname
  o.rmempty = false
  o.datatype = "hostname"

  -- Limit to (37-strlen("00000-")), i. e. 31 chars
  local mystrA = string.sub(string.format("%s-%s", addr, mac), 1, 31)
  local mystrB = string.sub(string.format("%s-%s", city, mac), 1, 31)
  local mystrC = string.sub(string.format("freifunk-%s", util.node_id()), 1, 31)
  local hostnameEx = s:option(cbi.ListValue, "_defhostname", string.format("Namensbeispiele: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; %s-", zip))
  hostnameEx:value("input", "(Manuelle Eingabe oben)")
  -- if mystrA ~= hostname then
    hostnameEx:value(mystrA, string.format("%s", mystrA))
  -- end
  -- if mystrB ~= hostname then
    hostnameEx:value(mystrB, string.format("%s", mystrB))
  -- end
  -- if mystrC ~= hostname then
    hostnameEx:value(mystrC, string.format("%s", mystrC))
  -- end
end

function M.handle(data)
  local zip = uci:get_first("gluon-node-info", 'location', "zip")
  local hostname
  local uihostname
  if data._defhostname ~= "input" then
      hostname = data._defhostname
  else
      hostname = data._hostname
  end
  uihostname = zip .. "-" .. hostname
  hostname = hostname:gsub(" ","-")
  hostname = hostname:gsub("%p","-")
  hostname = hostname:gsub("_","-")
  hostname = hostname:gsub("%-%-","-")
  hostname = zip .. "-" .. hostname
  hostname = hostname:sub(1, 42)

  uci:set("system", uci:get_first("system", "system"), "hostname", hostname)
  uci:save("system")
  uci:commit("system")
  if hostname ~= uihostname then
    os.execute("/bin/touch /tmp/hostname-changed-by-system")
    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
  end
end

return M
