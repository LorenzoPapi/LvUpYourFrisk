return (function()
	--TODO: refactor a bit cuz I'm tired of this
	local self = {}

	local circle = false
	local rx, ry, cx, cy, nsides = 0, 0, 0, 0, 1000

	local original = {}
	local gons = {}
	local resized = {}

	local rotation = 0
	local color = {1, 1, 1, 1}
	local resizing = false
	local timer = 0
	local seconds = 2

	local function rotatePoint(px, py)
		--3d arena == all signs equal
		local cosa, sina = math.cos(rotation), math.sin(rotation)
		return {x = (px - cx) * cosa - (py - cy) * sina + cx, y = (px - cx) * sina + (py - cy) * cosa + cy}
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

	function self.update(dt)
		if resizing then
			if timer < 1 then
				timer = timer + dt / (seconds)
			else
				timer = 0
				resizing = false
				recalculateVertices()
				calculateCentroid()
				resetOriginal()
			end
			for i=1,#resized do
				gons[i] = math.lerp(original[i], resized[i], timer)
			end
			recalculateVertices()
			calculateCentroid()
		end
	end

	function self.draw()
		local drawn = {}
		for i=1,#gons,2 do
			local p = rotatePoint(gons[i], gons[i+1])
			drawn[i] = p.x
			drawn[i+1] = p.y
		end
		lg.setLineWidth(5)
		if circle then
			lg.ellipse("line", cx, cy, rx, ry, nsides)
		else
			lg.polygon("line", drawn)
		end
		love.graphics.setColor(1, 1, 1, 1)
		lg.line(drawn[1], drawn[2], cx, cy)
		lg.setLineWidth(1)
	end

	function self.SetColor(rgba)
		local r = bit.band(bit.rshift(rgba, 24), 255) / 255.0
		local g = bit.band(bit.rshift(rgba, 16), 255) / 255.0
		local b = bit.band(bit.rshift(rgba, 8), 255) / 255.0
		local a = bit.band(rgba, 255) / 255.0
		color = {r, g, b, a}
	end

	function self.Ellipse(r1, r2, x, y, n)
		circle = true
		rx = r1
		ry = r2
		cx = x
		cy = y
		nsides = n or 1000
	end

	function self.Circle(r, x, y, n)
		self.Ellipse(r, r, x, y, n)
	end

	function self.Regular(r, x, y, n)
		self.Polygon(regularVertices(r, x, y, n))
	end

	function self.Rectangle(x1, y1, x3, y3)
		self.Polygon({x1, y1, x1, y3, x3, y3, x3, y1})
	end

	function self.RotateCWBy(a)
		self.Rotate(math.deg(rotation) + a)
	end

	function self.RotateCCWBy(a)
		self.Rotate(math.deg(rotation) + a)
	end

	function self.Rotate(a)
		rotation = math.rad(a)
		recalculateVertices()
	end

	function self.IsInside(x, y)
		if not circle then
			local higher0, higher1, inside, vtx0, vtx1
			vtx0 = {x = gons[#gons - 1], y = gons[#gons]}
			vtx1 = {x = gons[1], y = gons[2]}

			higher0 = (vtx0.y >= y)
			inside = false

			for i=2,#gons/2+1 do
				higher1 = (vtx1.y >= y)
				if higher0 ~= higher1 then
					if ( ((vtx1.y - y) * (vtx0.x - vtx1.x) >= (vtx1.x - x) * (vtx0.y - vtx1.y)) == higher1 ) then
						inside = not inside
					end
				end
				higher0  = higher1
				vtx0	 = vtx1
				vtx1	 = {x = gons[i], y = gons[i+1]}
			end
			return inside
		else
			if rx == ry then
				local ox, oy = x-cx, y-cy
				return ox^2+oy^2 < rx^2
			else
				local p = rotatePoint(x, y)
				return (p.x - cx)^2/rx^2 + (p.y - cy)^2/ry^2 < 1
			end
		end
	end

	function self.Polygon(t, regular)
		circle = false
		gons = t
		resetOriginal()
		recalculateVertices()
		calculateCentroid()
	end

	function self.Resize(new, s, immediate)
		circle = false
		seconds = s or seconds
		if immediate then
			self.Polygon(new)
		else
			resized = new
			if #gons > #new then
				local s = #new
				local sign = resized[#new] > resized[#new - 2] and 1 or -1
				for i=#new+1,#gons,2 do
					resized[i] = resized[s-1] + sign * 1
					resized[i+1] = resized[s] + sign * 1
					s = s + 2
				end
			elseif #gons < #new then
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