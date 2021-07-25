return (function()
	local discordRPC = require("discordRPC")
	discordRPC.initialize("868887349080227840", false)
	
	local self = {}

	local epoch = os.time()
	local presence = {
		details = "Title Screen",
		startTimestamp = epoch,
		largeImageKey = "rpc",
		largeImageText = "LVupYourFrisk"
	}
	local _p = presence
	presence = {}
	setmetatable(presence, {
		__newindex = function (t,k,v)
			_p[k] = v
			discordRPC.updatePresence(_p)
		end
	})
	discordRPC.updatePresence(_p)

	local function currentTime()
		return os.time() - epoch
	end

	function self.SetTitle(s)
		presence.details = s
	end

	function self.ClearTitle(reset)
		presence.details = reset and "" or "Playing Mod: " .. modName
	end

	function self.SetSubtitle(s)
		presence.state = s
	end

	function self.ClearSubtitle(reset)
		presence.state = reset and "" or "encounter"
	end

	function self.SetTime(time, countdown)
		if countdown then
			presence.endTimestamp = currentTime() + time
			presence.startTimestamp = 0
		else
			presence.startTimestamp = currentTime() - time
			presence.endTimestamp = 0
		end
	end

	function self.ClearTime(reset)
		if reset then
			presence.startTimestamp = 0
			presence.endTimestamp = 0
		else
			presence.startTimestamp = os.time()
		end
	end

	function love.quit()
		discordRPC.shutdown()
	end

	function self.update(dt)
		discordRPC.runCallbacks()
	end

	return self
end)()
