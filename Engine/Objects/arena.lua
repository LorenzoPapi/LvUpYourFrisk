return (function()
	local self = {}

	local circle = false

	local original = {}
	local gons = {}
	local resized = {}
	local vertices = {}

	local rx = 0
	local ry = 0
	local cx = 0
	local cy = 0
	local nsides = 1000
	local rotation = 0
	local color = {1, 1, 1, 1}
	local resizing = false
	local timer = 0
	local seconds = 2

	local function rotatePoint(px, py)
		--3d arena == all signs equal
		local a = math.rad(rotation)
		local cosa, sina = math.cos(a), math.sin(a)
		return {x = (px - cx) * cosa - (py - cy) * sina + cx, y = (px - cx) * sina + (py - cy) * cosa + cy}
	end

	local function recalculateVertices()
		table.clear(vertices)
		for i=1,#gons,2 do
			table.insert(vertices, rotatePoint(gons[i], gons[i+1]))
		end
	end

	local function calculateCentroid()
		for i=1,#gons,2 do
			cx = cx + gons[i]
			cy = cy + gons[i+1]
		end
		cx = 2 * cx / #gons
		cy = 2 * cy / #gons
	end

	local function resetOriginal()
		for i=1,#gons do
			original[i] = gons[i]
		end
	end

	function self.load()
		resetOriginal()
		recalculateVertices()
	end

	function self.update(dt)
		if (resizing) then
			if (timer < 1) then
				timer = timer + dt / (seconds)
			elseif (timer >= 1) then
				timer = 0
				resizing = false
				resetOriginal()
			end
			for i=1,#resized do
				gons[i] = math.lerp(original[i], resized[i], timer)
				recalculateVertices()
				calculateCentroid()
			end
		end
	end

	function self.draw()
		lg.setLineWidth(5)
		love.graphics.translate(cx, cy)
		love.graphics.rotate(math.rad(rotation))
		love.graphics.translate(-cx, -cy)
		love.graphics.setColor(color)
		if circle then
			lg.ellipse("line", cx, cy, rx, ry, nsides)
		else
			lg.polygon("line", gons)
			-- local a = {}
			-- for i=1,#vertices do
			-- 	table.insert(a, vertices[i].x)
			-- 	table.insert(a, vertices[i].y)
			-- end
			-- love.graphics.setLineWidth(10)
			-- lg.polygon("line", a)
			-- love.graphics.setLineWidth(1)
		end
		love.graphics.setColor(1, 1, 1, 1)
		lg.origin()
		lg.setLineWidth(1)
	end

	function self.SetColor(rgba)
		local r = bit.band(bit.rshift(rgba, 24), 255) / 255.0
		local g = bit.band(bit.rshift(rgba, 16), 255) / 255.0
		local b = bit.band(bit.rshift(rgba, 8), 255) / 255.0
		local a = bit.band(rgba, 255) / 255.0
		color = {r, g, b, a}
	end

	function self.Ellipse(r1, r2, x, y)
		circle = true
		rx = r1
		ry = r2
		cx = x
		cy = y
	end

	function self.Circle(r, x, y)
		self.Ellipse(r, r, x, y)
	end

	function self.Regular(r, x, y, n)
		self.Circle(r, x, y)
		nsides = n
	end

	function self.Rectangle(x1, y1, x3, y3)
		self.Polygon({x1, y1, x1, y3, x3, y3, x3, y1})
	end

	function self.RotateCWBy(a)
		rotation = (rotation + a) % 360
		recalculateVertices()
	end

	function self.RotateCCWBy(a)
		rotation = (rotation - a) % 360
		recalculateVertices()
	end

	function self.Rotate(a)
		rotation = a % 360
		recalculateVertices()
	end

	function self.IsInside(x, y)
		if not circle then
			local higher0, higher1, inside, vtx0, vtx1
	
			vtx0 = vertices[#vertices]
			vtx1 = vertices[1]

			higher0 = (vtx0.y >= y)
			inside = false
	
			for i=2,#vertices+1 do
				higher1 = (vtx1.y >= y)
				if (higher0 ~= higher1) then
					if ( ((vtx1.y - y) * (vtx0.x - vtx1.x) >= (vtx1.x - x) * (vtx0.y - vtx1.y)) == higher1 ) then
						inside = not inside
					end
				end
				higher0  = higher1
				vtx0	 = vtx1
				vtx1	 = vertices[i]
			end
			return inside
		else
			--TODO: check ellipse
			return false
		end
	end

	function self.Polygon(t)
		circle = false
		gons = t
		resetOriginal()
		calculateCentroid()
	end

	function self.Resize(new, s, immediate)
		seconds = s or seconds
		if (immediate) then
			self.Polygon(new)
		else
			resized = new
			if (#gons > #new) then
				local s = #new
				local sign = resized[#new] > resized[#new - 2] and 1 or -1
				for i=#new+1,#gons,2 do
					resized[i] = resized[s-1] + sign * 1
					resized[i+1] = resized[s] + sign * 1
					s = s + 2
				end
			elseif (#gons < #new) then
				local s = 1
				local old = {}
				for i=1,#gons do
					old[i] = gons[i]
				end
				for i=#gons+1,#new,2 do
					gons[i] = old[s] - 0.01
					gons[i+1] = old[s+1] - 0.01
					s = math.clamp(s + 2, 1, #old, true)
				end
				resetOriginal()
			end
			resizing = true
			timer = 0
		end
	end

	return self
end) ()