local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local lat = uci:get("gluon-node-info", 'location', "latitude")
local lon = uci:get("gluon-node-info", 'location', "longitude")
if not lat or not lon then
    os.execute('sh "/lib/gluon/ffgt-geolocate/senddata.sh"')
    os.execute('sleep 20')
end
