local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local au_enabled = uci:get_bool("autoupdater", "settings", "enabled")
  local s = form:section(cbi.SimpleSection, nil, i18n.translate(
    'You can provide your contact information here to '
      .. 'allow others to contact you. Please note that '
      .. 'this information will be visible <em>publicly</em> '
      .. 'on the internet together with your node\'s coordinates.'
    )
  )

  if not au_enabled then
    local s = form:section(cbi.SimpleSection, nil,
      [[<b>Achtung:</b> Dieser Knoten aktualisiert seine Firmware
      <b>nicht automatisch</b>. Die Angabe einer <b>g&uuml;ltigen</b> eMail-Adresse
      ist daher obligatorisch; alternativ reaktiviere bitte das automatische
      Update im <i>Expert Mode</i>.]])
  end
  if not fs.access("/tmp/is_online") then
    local s = form:section(cbi.SimpleSection, nil, [[<b>Keine Internetverbindung!</b>
       Die eMail-Adresse kann daher nicht verifiziert werden; entweder mu&szlig; die
       Verbindung zum Internet hergestellt oder aber der Autoupdating-Mechanismus
       reaktiviert werden (im  <i>Expert Mode</i>). Anderenfalls ist der Abschlu&szlig;
       der Konfiguration nicht m&ouml;glich.]])
  end

  local o = s:option(cbi.Value, "_contact", i18n.translate("Contact info"))
  o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
  -- o.rmempty = true
  o.datatype = "string"
  o.description = i18n.translate("e.g. E-mail or phone number")
  o.maxlen = 140
end

function M.handle(data)
  if data._contact ~= nil then
    uci:set("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact", data._contact)
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")
  else
    if not au_enabled then
      luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
    end
    uci:delete("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact")
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")
  end
end

return M
