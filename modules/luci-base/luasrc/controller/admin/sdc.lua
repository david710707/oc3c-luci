module("luci.controller.admin.sdc", package.seeall)

function index()
	local fs = require "nixio.fs"

	entry({"admin", "sdc"}, alias("admin", "sdc", "clockStatus"), _("Clock"), 80).index = true
	entry({"admin", "sdc", "clockStatus"}, template("admin_clock/index"), _("Status"), 1)
	entry({"admin", "sdc", "clockNtp"}, cbi("admin_clock/clockNtp"), _("NTP"), 2)
end
