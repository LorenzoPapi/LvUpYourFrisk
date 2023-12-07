return (function()
	local self = createSpecialTable({
		width = 570,
		height = 130,
		x = 320,
		y = 320.5,
		currentwidth = 570,
		currentheight = 130,
		currentx = 320,
		currenty = 320.5,
		isResizing = false,
		isMoving = false,
		isModifying = false,
		color = {1, 1, 1, 1},
		rotation = 0
	}, function(t, k, v)
		if not table.containsValue(t, debug.getinfo(3, "f").func) and type(v) ~= "function" then
			error("Cannot modify value " .. k .. " because it's readonly")
		end
	end)

	local movePlayer = true
	local vertices = {
			self.x - (self.width / 2), self.y - (self.height / 2),
			self.x - (self.width / 2), self.y + (self.height / 2),
			self.x + (self.width / 2), self.y + (self.height / 2),
			self.x + (self.width / 2), self.y - (self.height / 2)
	}
	local resizeTimer, moveTimer, seconds = 0, 0,2
	local nwidth, nheight = self.currentwidth, self.currentheight
	local nx, ny = self.currentx, self.currenty
	local hidden = false

	--3d arena == all signs equal	
	local function rotatePointAround0(px, py, rotation)
		return px * math.cos(rotation) - py * math.sin(rotation), py * math.cos(rotation) + px * math.sin(rotation)
	end

	local function rotatePointAroundArena(px, py)
		local x, y = rotatePointAround0(px, py, self.rotation)
		return x + self.currentx, y + self.currenty
	end

	local function rotateArena()
		local halfW, halfH = self.currentwidth / 2, self.currentheight / 2
		local px1, py1 = rotatePointAroundArena(-halfW, -halfH)
		local px2, py2 = rotatePointAroundArena(-halfW, halfH)
		local px3, py3 = rotatePointAroundArena(halfW, halfH)
		local px4, py4 = rotatePointAroundArena(halfW, -halfH)
		vertices = {px1, py1, px2, py2, px3, py3, px4, py4}
	end

	--Dimi thank you for the rotating arena so good
	function self.collide(px, py)
		local width, height = self.currentwidth - 4, self.currentheight - 4
		
		local r, l, u, d = width/2-8, -width/2+8, height/2-8, -height/2+8

		local apx, apy = rotateAround0(px - self.currentx, py - self.currenty, -self.rotation)

		local interX, interY = apx, apy
		if apx >= r then
			interX = r
		elseif apx <= l then
			interX = l
		end
		if apy >= u then
			interY = u
		elseif apy <= d then
			interY = d
		end

		interX, interY = rotateAround0(interX, interY, self.rotation)
		return apx <= r and apx >= l and apy <= u and apy >= d, {x = interX + ax, y = interY + ay}
	end

	function self.Resize(width, height, s)
		seconds = s or seconds
		assert(seconds >= 0, "\nTime of resizing cannot be negative!")
		if seconds == 0 then
			self.width = width
			self.height = height
			self.currentwidth = width
			self.currentheight = height
		else
			nwidth = width
			nheight = height
			self.isResizing = true
			self.isModifying = true
		end
	end

	function self.MoveTo(x, y, mp, s)
		movePlayer = mp or true
		seconds = s or seconds
		assert(seconds >= 0, "\nTime of moving cannot be negative!")
		if seconds == 0 then
			self.x = x
			self.y = y
			self.currentx = x
			self.currenty = y
		else
			nx = x
			ny = y
			self.isMoving = true
			self.isModifying = true
		end
	end

	function self.MoveToAndResize(x, y, w, h, mp, s)
		self.MoveTo(x, y, mp, s)
		self.Resize(w, h, s)
	end

	function self.Move(x, y, mp, s)
		self.MoveTo(self.x + x, self.y + y, mp, s)
	end

	function self.MoveAndResize(x, y, w, h, mp, s)
		self.MoveToAndResize(self.x + x, self.y + y, w, h, mp, s)
	end

	function self.SetColor(rgba)
		local r = bit.band(bit.rshift(rgba, 24), 255) / 255.0
		local g = bit.band(bit.rshift(rgba, 16), 255) / 255.0
		local b = bit.band(bit.rshift(rgba, 8), 255) / 255.0
		local a = bit.band(rgba, 255) / 255.0
		self.SetColor(r, g, b, a)
	end

	function self.SetColor(r, g, b, a)
		self.color = {r, g, b, a}
	end

	function self.Rotate(rot)
		self.rotation = math.rad(rot)
	end

	function self.Show()
		hidden = false
	end

	function self.Hide()
		hidden = true
	end

	function self.update(dt)
		if self.isResizing then
			self.currentwidth, self.currentheight = math.lerp(self.width, nwidth, resizeTimer), math.lerp(self.height, nheight, resizeTimer)
			if resizeTimer < 1 then
				resizeTimer = resizeTimer + dt / seconds
			else
				resizeTimer = 0
				self.width = self.currentwidth
				self.height = self.currentheight
				self.isResizing = false
				self.isModifying = false
			end
		end
		if self.isMoving then
			self.currentx, self.currenty = math.lerp(self.x, nx, moveTimer), math.lerp(self.y, ny, moveTimer)
			if movePlayer then
				Player.Move(self.currentx - Player.x, self.currenty - Player.y)
			end
			if moveTimer < 1 then
				moveTimer = moveTimer + dt / seconds
			else
				moveTimer = 0
				self.x = self.currentx
				self.y = self.currenty
				self.isMoving = false
				self.isModifying = false
			end
		end
		rotateArena()
	end

	function self.draw()
		if not hidden then
			lg.setLineWidth(5)
			lg.setColor(self.color)
			lg.polygon("line", vertices)
			lg.setColor(1, 1, 1, 1)
			lg.setLineWidth(1)
		end
	end

	return self
end) ()