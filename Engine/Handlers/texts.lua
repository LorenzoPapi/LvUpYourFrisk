--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.texts = {}

	function self.Create(content, font, x, y, fpc)
		local _text = {}
		_text.content = content or ""
		_text.font = font
		_text.x = x or 0
		_text.y = y or 0
		_text.fpc = fpc or 4	--frames per character
		_text.active = true
		_text.ended = false 	--has ended printing
		
		local spc = 0 			--seconds per character
		local timer = 0
		local current_char = 1
		local current = ""

		function _text.SetText(text, font)
			_text.content = text
			_text.font = font
			current = ""
			current_char = 1
		end

		function _text.update(dt)
			--TODO: text commands: might either create a system of "special" characters and insert them in the string, or make some markers or smth like that
			if _text.content:find("[instant]", 0, true) then
				_text.content = _text.content:gsub("%[instant]", "")
				_text.End()
			else
				spc = _text.fpc * dt
				if (current_char < _text.content:len()) then
					timer = timer + dt
				else
					timer = 0
				end
				if (timer >= spc) then
					current = _text.content:sub(1, current_char)
					timer = timer - spc
					current_char = current_char + 1
				end
				if (current_char == _text.content:len()) then
					_text.End()
				end
			end
		end

		function _text.draw()
			lg.print(current, fonts[_text.font], _text.x, _text.y)
			lg.origin()
		end

		function _text.End()
			current = _text.content
			current_char = _text.content:len()
			_text.ended = true
		end

		function _text.Remove()
			_text.active = false
		end

		table.insert(self.texts, _text)
		return _text
	end

	function self.draw()
		for i=1,#self.texts do
			if (self.texts[i] and self.texts[i].active) then
				self.texts[i].draw()
			else
				table.remove(self.texts, i)
			end
		end
	end

	function self.update(dt)
		for i=1,#self.texts do
			if (self.texts[i] and self.texts[i].active) then
				self.texts[i].update(dt)
			else
				table.remove(self.texts, i)
			end
		end
	end

	function self.Reset()
		table.clear(self.texts)
	end

	return self
end)()