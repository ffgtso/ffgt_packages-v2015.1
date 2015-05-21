local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'
local fs = require "nixio.fs"

local sites = {}
local M = {}

function M.section(form)
    local lat = uci:get("gluon-node-info", sname, "latitude")
    local lon = uci:get("gluon-node-info", sname, "longitude")
    if not lat then lat=0 end
    if not lon then lon=0 end
    if ((lat == 0) or (lat == 51)) and ((lon == 0) or (lon == 9)) then
	    local s = form:section(cbi.SimpleSection, nil, [[
	    Geo-Lokalisierung schlug fehl :( Hier hast Du die Möglichkeit,
	    die Community, mit der sich Dein Knoten verbindet, auszuwählen.
	    Bitte denke daran, dass dein Router sich dann nur mit dem Netz
	    der ausgewählten Community verbindet und ggf. lokales Meshing nicht
	    funktioniert bei falscher Auswahl. Vorzugsweise schließt Du
	    Deinen Freifunk-Knoten jetzt per gelbem Port an Deinen Internet-
	    Router an und startest noch mal von vorn.
	    ]])
	
    	uci:foreach('siteselect', 'site',
    	function(s)
    		table.insert(sites, s['.name'])
    	end
    	)
	
	    local o = s:option(cbi.ListValue, "community", "Community")
    	o.rmempty = false
	    o.optional = false

        local unlocode = uci:get_first("gluon-node-info", "location", "locode")
	    if uci:get_first("gluon-setup-mode", "setup_mode", "configured") == "0" then
	    	o:value(unlocode, uci:get('siteselect', unlocode, 'sitename'))
	    else
		    o:value(site.site_code, site.site_name)
	    end

	    for index, site in ipairs(sites) do
	    	o:value(site, uci:get('siteselect', site, 'sitename'))
        end
    end

end

function M.handle(data)

	if data.community ~= site.site_code then
		uci:set('siteselect', site.site_code, "secret", uci:get('fastd', 'mesh_vpn', 'secret'))
		uci:save('siteselect')
		uci:commit('siteselect')

        -- Deleting this unconditionally would leave the node without a secret in case the
        -- check fails later on. Moving the delete down into the if-clauses.
		-- uci:delete('fastd', 'mesh_vpn', 'secret')

		local secret = uci:get('siteselect', data.community, 'secret')
		
		if not secret or not secret:match(("%x"):rep(64)) then
			uci:delete('siteselect', data.community, 'secret')
		else
			uci:delete('fastd', 'mesh_vpn', 'secret')
            uci:set('fastd', 'mesh_vpn', "secret", secret)
		end
				
		uci:save('fastd')
		uci:commit('fastd')

        -- We need to store the selection somewhere. To make this simple,
        -- put it into gluon-node-info:location.siteselect ...
        uci:delete('gluon-node-info', 'location', 'siteselect')
        uci:set('gluon-node-info', 'location', 'siteselect', data.community)
        uci:save('gluon-node-info')
        uci:commit('gluon-node-info')

		fs.copy(uci:get('siteselect', data.community , 'path'), '/lib/gluon/site.conf')
		
		os.execute('sh "/lib/gluon/site-upgrade"')
	end
end

return M