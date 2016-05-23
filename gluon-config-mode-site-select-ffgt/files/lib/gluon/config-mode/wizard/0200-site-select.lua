local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'
local fs = require "nixio.fs"
local sys = luci.sys

local sites = {}
local M = {}

function M.section(form)
    local lat = uci:get_first("gluon-node-info", 'location', "latitude")
    local lon = uci:get_first("gluon-node-info", 'location', "longitude")
    local unlocode = uci:get_first("gluon-node-info", "location", "locode")
    if not lat then lat=0 end
    if not lon then lon=0 end
    -- FXIME! This is the totally wrong place, but in geoloc/0200-geo-location.lua
    -- lua/luci fail due to what seems to be a caching issue.
    if not unlocode or (lat == "51" and lon == "9") then
      luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard-pre"))
    end
    if ((lat == 0) or (lat == "51")) and ((lon == 0) or (lon == "9")) then
	    local s = form:section(cbi.SimpleSection, nil, [[
	    Geo-Lokalisierung schlug fehl :( Hier hast Du die Möglichkeit,
	    die Community, mit der sich Dein Knoten verbindet, auszuwählen.
	    Bitte denke daran, dass Dein Router sich dann nur mit dem Netz
	    der ausgewählten Community verbindet und ggf. lokales Meshing nicht
	    funktioniert bei falscher Auswahl. Vorzugsweise schließt Du
	    Deinen Freifunk-Knoten jetzt an Deinen Internet-Router an und
	    startest noch mal von vorn.
	    ]])
	
    	uci:foreach('siteselect', 'site',
    	function(s)
    		table.insert(sites, s['.name'])
    	end
    	)

	    local o = s:option(cbi.ListValue, "community", "Community")
    	o.rmempty = false
	    o.optional = false

	    if uci:get_first("gluon-setup-mode", "setup_mode", "configured") == "0" then
	    	o:value(unlocode, uci:get_first('siteselect', unlocode, 'sitename'))
	    else
		    o:value(site.site_code, site.site_name)
	    end

	    for index, site in ipairs(sites) do
	    	o:value(site, uci:get('siteselect', site, 'sitename'))
        end
--    else
--        local unlocode = uci:get_first("gluon-node-info", "location", "locode")
--        local s = form:section(cbi.SimpleSection, nil, [[Geo-Lokalisierung erfolgreich.]])
--        local o = s:option(cbi.DummyValue, "community", "Community-Code")
--    	  o.rmempty = false
--        o.optional = false
--        o.value = unlocode
--        -- FIXME! Why isn't this working below? It works with cbi.Value or cbi.ListValue, but with cbi.DummyValue I get:
--        -- /lib/gluon/config-mode/wizard//0200-site-select.lua:66: bad argument #2 to 'get' (string expected, got nil)
--        -- (with line 66: local secret = uci:get_first('siteselect', data.community, 'secret'))
    end
end

function M.handle(data)
    if data.community then
        --if data.community ~= site.site_code then
            -- FIXME! Won't work as unlocode is the NEW setting already and the former use of site.site_code doesn't apply for FFGT
            --local unlocode = uci:get_first("gluon-node-info", "location", "locode")
            --uci:set('siteselect', unlocode, "secret", uci:get('fastd', 'mesh_vpn', 'secret'))
            --uci:save('siteselect')
            --uci:commit('siteselect')
            uci:set('gluon-node-info', 'location', 'debug1a', data.community)
            uci:set('gluon-node-info', 'location', 'debug1b', 'done')
            uci:save('gluon-node-info')
            uci:commit('gluon-node-info')


            -- Deleting this unconditionally would leave the node without a secret in case the
            -- check fails later on. Moving the delete down into the if-clauses.
            -- uci:delete('fastd', 'mesh_vpn', 'secret')

            local secret = uci:get_first('siteselect', data.community, 'secret')

            if not secret or not secret:match(("%x"):rep(64)) then
                uci:delete('siteselect', data.community, 'secret')
            else
                -- uci:delete('fastd', 'mesh_vpn', 'secret')
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
        --end
    else
        -- The UN/LOCODE is the relevant information. No user servicable parts in the UI ;)
        local unlocode = uci:get_first("gluon-node-info", 'location', "locode")
        local current = uci:get_first('gluon-node-info', 'location', 'siteselect')
        --uci:set('siteselect', unlocode, "secret", uci:get('fastd', 'mesh_vpn', 'secret'))
        --uci:save('siteselect')
        --uci:commit('siteselect')

        -- Actually, fuck you, LuCI. If this doesn't work, although imho it should, let's
        -- use the shell to do what you resist of doing. I'm fed with this shit. FIXME!
        -- uci:set('gluon-node-info', 'location', 'debug2a', unlocode)
        -- uci:set('gluon-node-info', 'location', 'debug2b', 'done')
        -- uci:save('gluon-node-info')
        -- uci:commit('gluon-node-info')
        --
        -- The following does work ...
        --
        -- sys.exec(string.format("/sbin/uci set gluon-node-info.@location[0].debug2=%c%s%c 2>/dev/null", 39, "yes", 39))
        -- sys.exec(string.format("/sbin/uci commit gluon-node-info 2>/dev/null"))

        local secret = uci:get_first('siteselect', unlocode, 'secret')

        if not secret or not secret:match(("%x"):rep(64)) then
            uci:delete('siteselect', unlocode, 'secret')
            uci:save('siteselect')
            uci:commit('siteselect')
        else
            uci:delete('fastd', 'mesh_vpn', 'secret')
            uci:set('fastd', 'mesh_vpn', "secret", secret)
            uci:save('fastd')
            uci:commit('fastd')
        end

        -- We need to store the selection somewhere. To make this simple,
        -- put it into gluon-node-info.location.siteselect ...
        --uci:delete('gluon-node-info', 'location', 'siteselect')
        uci:set('gluon-node-info', 'location', 'siteselect', unlocode)
        uci:save('gluon-node-info')
        uci:commit('gluon-node-info')
        sys.exec(string.format("/sbin/uci set gluon-node-info.@location[0].siteselect=%c%s%c 2>/dev/null", 39, unlocode, 39))
        sys.exec(string.format("/sbin/uci commit gluon-node-info 2>/dev/null"))

        fs.copy(uci:get('siteselect', unlocode, 'path'), '/lib/gluon/site.conf')
        -- os.execute("/bin/touch /tmp/need-to-run-site-upgrade")
        -- os.execute('sh "/lib/gluon/site-upgrade"')
        os.execute('/lib/gluon/upgrade/400-mesh-vpn-fastd')
        os.execute('/lib/gluon/upgrade/320-gluon-mesh-batman-adv-core-wireless')
    end
end

return M
