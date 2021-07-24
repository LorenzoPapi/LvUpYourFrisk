--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.sprites = {}
	
	function self.Create(name, x, y, r, xscale, yscale, xpivot, ypivot)
		local _sprite = {}
		_sprite.frame = 1
		_sprite.rate = 1/30
		_sprite.list = {name or ""}
		_sprite.mode = "loop"
		_sprite.x = x or 0
		_sprite.y = y or 0
		_sprite.rotation = r or 0
		_sprite.xscale = xscale or 1
		_sprite.yscale = yscale or 1
		_sprite.xpivot = xpivot or 0
		_sprite.ypivot = ypivot or 0
		_sprite.width = sprites[name]:getWidth()
		_sprite.height = sprites[name]:getHeight()
		_sprite.alpha = 1
		_sprite.color = {1, 1, 1, _sprite.alpha}
		_sprite.active = true

		local timer = 0

		function _sprite.Set(spr)
			_sprite.frame = 1
			_sprite.list = {spr}
		end

		function _sprite.SetColor(r, g, b, a)
			_sprite.color = {r, g, b, a or _sprite.alpha}
		end

		function _sprite.SetColor32(r, g, b, a)
			_sprite.color = {r/255, g/255, b/255, a/255 or _sprite.alpha/255}
		end

		function _sprite.SetPivot(x, y)
			_sprite.xpivot = x
			_sprite.ypivot = y
		end

		function _sprite.Scale(x, y)
			_sprite.xscale = x
			_sprite.yscale = y
		end

		function _sprite.SetAnimation(table, r, m)
			_sprite.list = table
			_sprite.frame = 1
			_sprite.rate = r
			_sprite.mode = m
		end

		function _sprite.MoveTo(x, y)
			_sprite.x = x
			_sprite.y = y
		end

		function _sprite.Move(x, y)
			_sprite.MoveTo(_sprite.x + x, _sprite.y + y)
		end

		function _sprite.Remove()
			_sprite.active = false
		end

		function _sprite.draw()
			local s = _sprite
			table.remove(s.color)
			table.insert(s.color, s.alpha)
			lg.setColor(s.color)
			lg.draw(sprites[s.list[s.frame]], s.x, s.y, s.rotation, s.xscale, s.yscale, s.xpivot, s.ypivot)
			lg.setColor(1, 1, 1, 1)
		end

		function _sprite.update(dt)
			if (#_sprite.list > 1) then
				local s = _sprite
				if (s.frame <= #s.list) then
					timer = timer + dt
				else
					timer = 0
				end
				if (timer >= s.rate) then
					timer = timer - s.rate
					s.frame = s.frame + 1
				end
				if (s.frame == (#s.list + 1)) then
					s.frame = 1
					if (s.mode == "oneshot") then
						-- Make list contain only last frame
						s.list = {s.list[#s.list]}
					elseif (s.mode == "oneshotempy") then
						s.list = {"empty"}
					end
				end
			end
		end

		table.insert(self.sprites, _sprite)
		return _sprite
	end

	function self.draw()
		for i=1,#self.sprites do
			local spr = self.sprites[i]
			if (spr.active) then
				spr.draw()	
			else
				table.remove(self.sprites, i)
			end
		end
	end

	function self.update(dt)
		for i=1,#self.sprites do
			local spr = self.sprites[i]
			if (spr.active) then
				spr.update(dt)	
			else
				table.remove(self.sprites, i)
			end
		end
	end

	return self
end)()