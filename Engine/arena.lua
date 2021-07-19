--Arena file!
return (function()
	local self = {}

	local circle = false

	local gons = {}
	local vertices = {}

	local rx = 0
	local ry = 0
	local cx = 0
	local cy = 0
	local nsides = 1000
	local rotation = 0
	local color = {1, 1, 1, 1}

	local function rotatePoint(px, py)
		local a = math.rad(rotation)
		local cosa, sina = math.cos(a), math.sin(a)
		return {x = (px - cx) * cosa + (py - cy) * sina + cx, y = (px - cx) * sina + (py - cy) * cosa + cy}
	end

	local function recalculateVertices()
		table.clear(vertices)
		for i=1,#gons,2 do
			table.insert(vertices, rotatePoint(gons[i], gons[i+1]))
		end
	end

	function self.load()
		recalculateVertices()
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
			local a = {}
			for i=1,#vertices do
				table.insert(a, vertices[i].x)
				table.insert(a, vertices[i].y)
			end
			love.graphics.setLineWidth(10)
			--lg.polygon("line", a)
			love.graphics.setLineWidth(1)
		end
		love.graphics.setColor(1, 1, 1, 1)
		lg.origin()
		lg.setLineWidth(1)
	end

	function self.Reset()
		table.clear(gons)
		table.clear(vertices)
		circle = false
		rotation = 0
		radius = 0
		cx = 0
		cy = 0
		nsides = 1000
	end

	function self.SetColor(rgb)
		local r = bit.band(bit.rshift(rgb, 16), 255)
		local g = bit.band(bit.rshift(rgb, 8), 255)
		local b = bit.band(rgb, 255)
		print(r, g, b)
		color = {r/255.0, g/255.0, b/255.0, 1}
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
				vtx0     = vtx1
				vtx1     = vertices[i]
			end
			return inside
		else
			local rotated = rotatePoint(x, y)
			return ((rotated.x/rx)^2+(rotated.y/ry)^2<1)
		end
	end

	function self.Polygon(t)
		circle = false
		gons = t
		for i=1,#gons,2 do
			cx = cx + gons[i]
			cy = cy + gons[i+1]
		end
		cx = 2 * cx / #gons
		cy = 2 * cy / #gons
	end

	return self
end) ()