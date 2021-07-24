--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.MachineName = ""
	self.OsType = love.system.getOS()
	self.cameraX = 0
	self.cameraY = 0
	self.WindowX, self.WindowY = love.window.getPosition()
	self.WindowName = "LVup Your Frisk"
	local frame = 0

	local shakeThread = love.thread.newThread([[
		local total, int, decrease = ...

		local pos = love.thread.getChannel("pos")
		local f = love.thread.getChannel("frame")

		int = int or 3
		local frame = f:pop()
		local baseInt = int

		while true do
			if frame then
				if frame >= total then
					break
				end
				if decrease then
					--LERP
					int = baseInt * (1 - (frame / total))
				end
				pos:push({math.cos(frame) * int * math.random(), math.sin(frame) * int * math.random()})
			end
			if (love.thread.getChannel("kill"):pop()) then
				break
			end
			frame = f:pop()
		end
	]])

	function self.Load()
		if (self.OsType == "Windows") then
			self.MachineName = os.getenv("USERNAME")
		else
			self.MachineName = os.getenv("USER")
		end
	end

	function self.DestroyWindow()
		love.event.quit()
	end

	function self.MoveCamera(x, y)
		self.MoveCameraTo(self.cameraX + x, self.cameraY + y)
	end

	function self.MoveCameraTo(x, y)
		self.cameraX = x
		self.cameraY = y
	end

	function self.ResetCamera()
		self.MoveCameraTo(0, 0)
	end

	function self.ShakeScreen(frames, int, decrease)
		shakeThread:start(frames, int, decrease)
	end

	function self.StopShake()
		if (shakeThread:isRunning()) then
			love.thread.getChannel("kill"):push("DIE")
			frame = 0
		end
	end

	function self.MoveWindow(x, y)
		self.MoveWindowTo(self.WindowX + x, self.WindowY + y)
	end

	function self.MoveWindowTo(x, y)
		self.WindowX = x
		self.WindowY = y
		love.window.setPosition(x, y)
	end

	function self.draw()
		lg.translate(self.cameraX, self.cameraY)
	end

	function self.update(dt)
		love.window.setTitle(self.WindowName)
		if (shakeThread:isRunning()) then
			local pos = love.thread.getChannel("pos"):pop()
			if (pos) then
				self.MoveCameraTo(pos[1], pos[2])
			end
			frame = frame + 1
			love.thread.getChannel("frame"):push(frame)
		end
	end

	function love.threaderror(thread, errorstr)
		error(errorstr)
	end
	
	return self
end)()