local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
    local lat = uci:get_first("gluon-node-info", 'location', "latitude")
    local lon = uci:get_first("gluon-node-info", 'location', "longitude")
    if not lat then lat=0 end
    if not lon then lon=0 end
    if (lat == 0) and (lon == 0) then
        local s = form:section(cbi.SimpleSection, nil,
        [[Es sind keine Koordinaten hinterlegt. Bitte trage sie ein oder versuche die
        automatische Lokalisierung (anhand der empfangenen Funknetze bzw. der IP-Adresse)
        &uuml;ber die Schaltfl&auml;che "Geolocate" oben. Bitte beachte, da&szlig; Dein
        Knoten über die gelben(!) Ports Internet-Zugang haben mu&szlig;.]])
    elseif (lat == "51") and (lon == "9") then
        local s = form:section(cbi.SimpleSection, nil,
        [[<b>Die automatische Lokalisierung ist fehlgeschlagen.</b> Bitte trage Deine
        Koordinaten, gerne mit Hilfe der Karte, ein. Bitte beachte, da&szlig; Dein
        Knoten über die gelben(!) Ports Internet-Zugange haben mu&szlig;,
        damit die Karte angezeigt und die Daten validiert werden k&ouml;nnen.]])
    else
        local addr = uci:get_first("gluon-node-info", 'location', "addr")
        local city = uci:get_first("gluon-node-info", 'location', "city")
        local zip = uci:get_first("gluon-node-info", 'location', "zip")
        local unlocode = uci:get_first("gluon-node-info", "location", "locode")
        local community = uci:get_first('siteselect', unlocode, 'sitename') or unlocode
        local mystr = string.format("Lokalisierung des Knotens erfolgreich; bitte Daten &uuml;berpr&uuml;fen:<br></br><b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, community)
        local s = form:section(cbi.SimpleSection, nil, mystr)
    end
end

function M.handle(data)
  return
end

return M
