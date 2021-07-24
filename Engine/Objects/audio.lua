--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	local looping = {}
	local paused = {}

	function self.GetTotalTime(file)
		return sounds[file]:getDuration()
	end

	function self.GetPlayTime(file)
		return sounds[file]:tell()
	end

	local function Play(file, type, loop, volume)
		local v = volume or (type == "music" and 1 or 0.65)
		sounds[file]:setVolume(v)
		sounds[file]:play()
		if loop then
			table.insert(looping, file)
		end
	end

	function self.PlaySound(file, loop, volume)
		Play(file, "sound", loop, volume)
	end

	function self.PlayMusic(file, loop, volume)
		Play(file, "music", loop, volume)
	end

	function self.SetPitch(file, pitch)
		sounds[file]:setPitch(pitch)
	end

	function self.GetPitch(file)
		return sounds[file]:getPitch()
	end

	function self.SetVolume(file, volume)
		return sounds[file]:setVolume(volume)
	end

	function self.GetPitch(file)
		return sounds[file]:getVolume()
	end

	function self.Stop(file)
		sounds[file]:stop()
	end

	function self.Pause(file)
		sounds[file]:pause()
		table.insert(paused, file)
	end

	function self.Unpause(file)
		sounds[file]:play()
		table.remove(paused, table.indexof(paused, file))
	end

	function self.SetPlayTime(file, seconds)
		sounds[file]:seek(seconds)
	end

	function self.NotPlaying(file)
		return not sounds[file]:isPlaying()
	end

	function self.StopAll()
		for v in pairs(sounds) do
			if not self.NotPlaying(v) then
				self.Stop(v)
			end
		end
	end

	function self.PauseAll()
		for v in pairs(sounds) do
			if not self.NotPlaying(v) then
				self.Pause(v)
			end
		end
	end

	function self.UnpauseAll()
		for v in pairs(paused) do
			if not self.NotPlaying(v) then
				self.Unpause(v)
			end
		end
	end

	function self.update(dt)
		for _,v in pairs(looping) do
			if self.NotPlaying(v) and not table.contains(paused, v) then
				sounds[v]:play()
			end
		end
	end

	return self
end)()