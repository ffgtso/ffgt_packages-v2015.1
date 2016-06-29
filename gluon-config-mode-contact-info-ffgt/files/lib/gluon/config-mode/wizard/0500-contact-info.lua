local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local fs = require "nixio.fs"

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

  if not fs.access("/tmp/is_online") then
    os.execute('/lib/gluon/config-mode/check4online.sh')
  end

  if not au_enabled then
    local s = form:section(cbi.SimpleSection, nil,
      [[<b>Achtung:</b> Dieser Knoten aktualisiert seine Firmware
      <b>nicht</b> automatisch. Die Angabe einer <b>g&uuml;ltigen</b> eMail-Adresse
      ist daher obligatorisch; alternativ reaktiviere bitte das automatische
      Update im <i>Expert Mode</i>.]])
  end
  if not fs.access("/tmp/is_online") then
    local s = form:section(cbi.SimpleSection, nil, [[<b>Keine Internetverbindung!</b>
       Die eMail-Adresse kann daher nicht verifiziert werden; entweder mu&szlig; die
       Verbindung zum Internet hergestellt oder aber der Autoupdate-Mechanismus
       reaktiviert werden (im  <i>Expert Mode</i>). Anderenfalls ist der Abschlu&szlig;
       der Konfiguration nicht m&ouml;glich.]])
  end
  if fs.access("/tmp/invalid_email") then
    local s = form:section(cbi.SimpleSection, nil, [[<b>EMail-Pr&uuml;fung fehlgeschlagen!</b>
       Die eingegebene eMail-Adresse scheint nicht g&uuml;ltig zu sein, bitte eine g&uuml;ltige
       eintragen oder den Autoupdate-Mechanismus reaktivieren. Anderenfalls ist der Abschlu&szlig;
       der Konfiguration nicht m&ouml;glich.]])
  end

  local o = s:option(cbi.Value, "_contact", i18n.translate("Contact info"))
  o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
  -- o.rmempty = true
  o.datatype = "string"
  o.description = i18n.translate("E-mail")
  o.maxlen = 140

  local s = form:section(cbi.SimpleSection, nil, [[Hier kann eine URL angegeben werden,
     die auf den Aufsteller/Aufstellort hinweist. Diese URL wird auf der Knotenkarte
     bei den Knotendaten &ouml;ffentlich einsehbar sein.]])
  local o = s:option(cbi.Value, "_infourl", i18n.translate("Location URL"))
  o.default = uci:get_first("gluon-node-info", "owner", "infourl", "")
  -- o.rmempty = true
  o.datatype = "string"
  o.description = i18n.translate("URL")
  o.maxlen = 255
end

function M.handle(data)
  function url_encode(str)
    if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
    end
    return str
  end

  if data._contact ~= nil then
    if not fs.access("/tmp/is_online") then
      luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
    else
      uci:set("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact", data._contact)
      uci:save("gluon-node-info")
      local isvalid=os.execute(string.format("/lib/gluon/ffgt-email-verification/verify-email.sh \"%s\" >/dev/null", url_encode(data._contact)))
      if isvalid ~= 0 then
        os.execute("touch /tmp/invalid_email")
        luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
      else
        os.execute("/bin/rm /tmp/invalid_email")
      end
    end

    uci:commit("gluon-node-info")
  else
    if not au_enabled then
      luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
    end
    uci:delete("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact")
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")
  end

  if data._infourl ~= nil then
    uci:set("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "infourl", data._infourl)
    uci:save("gluon-node-info")
    uci:commit("gluon-node-info")
  end
end

return M
