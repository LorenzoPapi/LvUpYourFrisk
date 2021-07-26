return (function()
	local discordRPC = require("discordRPC")
	discordRPC.initialize("868887349080227840", false)
	
	local self = {}

	local presence = createSpecialTable({
		details = "Title Screen",
		largeImageKey = "rpc",
		largeImageText = "LVupYourFrisk"
	}, function(proxy, k, v)
		discordRPC.updatePresence(proxy)
	end)

	presence.startTimestamp = os.time()

	function self.SetTitle(s)
		presence.details = s
	end

	function self.ClearTitle(reset)
		self.SetTitle(reset and "" or "Playing Mod: " .. modName)
	end

	function self.SetSubtitle(s)
		presence.state = s
	end

	function self.ClearSubtitle(reset)
		self.SetSubtitle(reset and "" or "encounter")
	end

	function self.SetTime(time, countdown)
		presence.endTimestamp = countdown and os.time() + time or 0
		presence.startTimestamp = countdown and os.time() or os.time() - time
	end

	function self.ClearTime(reset)
		self.SetTime(reset and os.time() or 0)
	end

	function love.quit()
		discordRPC.shutdown()
	end

	function self.update(dt)
		discordRPC.runCallbacks()
	end

	return self
end)()
