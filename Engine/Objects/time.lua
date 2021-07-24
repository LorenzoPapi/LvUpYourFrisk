return (function()

	local self = {}
	self.time = 0
	self.dt = 0
	self.mult = 0
	--self.wave = -1 NYI
	self.frameCount = 0
	local timer = 0

	function self.update(dt)
		self.dt = dt
		self.mult = dt * 60
		self.frameCount = self.frameCount + 1
		timer = timer + dt
		if (timer >= 1) then
			timer = 0
			self.time = self.time + 1
		end
	end

	return self
end)()