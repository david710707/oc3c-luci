local readmeURL = "https://github.com/openwrt/packages/blob/master/net/vpnbypass/files/README.md"

m = Map("vpnbypass", translate("VPN Bypass Settings"))

h = m:section(NamedSection, "config", "vpnbypass", translate("Service Status"))
local packageName = "vpnbypass"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local http = require "luci.http"
local dispatcher = require "luci.dispatcher"
en = h:option(Button, "__toggle")
if enabledFlag ~= "1" then
	en.title      = translate("Service is disabled/stopped")
	en.inputtitle = translate("Enable/Start")
	en.inputstyle = "apply important"
else
	en.title      = translate("Service is enabled/started")
	en.inputtitle = translate("Stop/Disable")
	en.inputstyle = "reset important"
end
function en.write()
	enabledFlag = enabledFlag == "1" and "0" or "1"
	uci:set(packageName, "config", "enabled", enabledFlag)
	uci:save(packageName)
	uci:commit(packageName)
	if enabledFlag == "0" then
		sys.init.stop(packageName)
		sys.init.disable(packageName)
	else
		sys.init.enable(packageName)
		sys.init.start(packageName)
	end
	if dispatcher.lookup("admin/vpn") then
		http.redirect(dispatcher.build_url("admin/vpn/" .. packageName))
	else
		http.redirect(dispatcher.build_url("admin/services/" .. packageName))
	end
end

s = m:section(NamedSection, "config", "vpnbypass", translate("VPN Bypass Rules"))

-- Local Ports
p1 = s:option(DynamicList, "localport", translate("Local Ports to Bypass"), translate("Local ports to trigger VPN Bypass"))
p1.datatype    = "portrange"
-- p1.placeholder = "0-65535"
p1.addremove = false
p1.optional = false

-- Remote Ports
p2 = s:option(DynamicList, "remoteport", translate("Remote Ports to Bypass"), translate("Remote ports to trigger VPN Bypass"))
p2.datatype    = "portrange"
-- p2.placeholder = "0-65535"
p2.addremove = false
p2.optional = false

-- Local Subnets
r1 = s:option(DynamicList, "localsubnet", translate("Local IP Addresses to Bypass"), translate("Local IP addresses or subnets with direct internet access (outside of the VPN tunnel)"))
r1.datatype    = "ip4addr"
-- r1.placeholder = ip.new(m.uci:get("network", "lan", "ipaddr"), m.uci:get("network", "lan", "netmask"))
r1.addremove = false
r1.optional = false

-- Remote Subnets
r2 = s:option(DynamicList, "remotesubnet", translate("Remote IP Addresses to Bypass"), translate("Remote IP addresses or subnets which will be accessed directly (outside of the VPN tunnel)"))
r2.datatype    = "ip4addr"
-- r2.placeholder = "0.0.0.0/0"
r2.addremove = false
r2.optional = false

-- Domains
d = Map("dhcp")
s4 = d:section(TypedSection, "dnsmasq")
s4.anonymous = true
di = s4:option(DynamicList, "ipset", translate("Domains to Bypass"),
    translate("Domains to be accessed directly (outside of the VPN tunnel), see ")
		.. [[<a href="]] .. readmeURL .. [[#bypass-domains-formatsyntax" target="_blank">]]
    .. translate("README") .. [[</a> ]] .. translate("for syntax"))
function d.on_after_commit(map)
    sys.init.restart("dnsmasq")
end

return m, d
