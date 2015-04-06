local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local enabled = uci:get_bool("autoupdater", "settings", "enabled")
  if enabled then
    local s = form:section(cbi.SimpleSection, nil,
      [[Dieser Knoten aktualisiert seine Firmware automatisch, sobald
      eine neue Version vorliegt.]])
  else
    local s = form:section(cbi.SimpleSection, nil,
      [[Dieser Knoten aktualisiert seine Firmware <b>nicht automatisch</b>.
      Bitte reaktiviere diese Funktion im <i>Expert Mode</i>.]])
  end
end

function M.handle(data)
  return
end

return M
