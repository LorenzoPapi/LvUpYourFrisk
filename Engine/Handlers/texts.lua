--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}
	local commands = {"w", "instant", "func", "color", "alpha"}

	self.texts = {}

	local function splitTableInLines(content)
		local cont = content or ""
		if (type(content) == "table") then
			cont = ""
			for _,t in ipairs(content) do
				cont = cont .. " " .. t .. "\n"
			end
		end
		return cont
	end

	local function getCommands(content, t)
		if (content:find("%[.-]")) then
			local i = 1
			local cmdindex = -1
			local cmd = ""
			local c = ""
			local cleaned = content
			while i <= #content do
				c = content:sub(i, i)
				if (c == "[") then
					cmdindex = i
					cmd = ""
					while not (c == "]") do
						cmd = cmd .. c
						i = i + 1
						c = content:sub(i, i)
					end
					cmd = cmd:sub(2)
					if ((cmd:find(":")) and table.contains(commands, cmd:split()[1])) or table.contains(commands, cmd) then
						t[cmdindex] = cmd
						content = content:gsub(cmd, "")
						i = 1
					end
				else
					i = i + 1
				end
			end
			for k,v in pairs(t) do
				cleaned = cleaned:gsub("%[" .. v .. "%]", "")
			end
			return cleaned
		end
		return content
	end

	function self.Create(content, font, x, y, speed)
		local _text = {}
		-- GENIUS PLAN!!
		-- check for when the command start and, every time the char variable increase, check if there's an action to perform
		-- create a function that takes the action and does whatever the fuck it's needed to be done
		-- ebic plan
		local indextocommand = {}
		_text.x = x or 0
		_text.y = y or 0
		_text.speed = speed or 4	--frames per character
		_text.color = {1, 1, 1, 1}
		_text.active = true
		_text.ended = false 	--has ended printing
		
		local spc = 0 			--seconds per character
		local timer = 0
		local char = 1
		local current = ""

		function _text.SetText(text, font)
			_text.content = getCommands(splitTableInLines(text), indextocommand)
			_text.font = font
			_text.ended = false
			current = ""
			char = 1
			UI.SetCurrentText(_text)
		end

		_text.SetText(content, font)

		local function executeCommand(cmd, obj)
			if (cmd:find(":")) then
				local command, args = cmd:split()[1], cmd:split()[2]
				if (command == "w") then
					timer = -(tonumber(args) * obj.speed / love.timer.getFPS())
				elseif (command == "color") then
					obj.SetColor(tonumber(args:upper(), 16))
				end
			else
				if (cmd == "instant") then
					if (#indextocommand > 1) then
						for k,v in pairs(indextocommand) do
							indextocommand[k] = nil
							executeCommand(v, obj)
						end
					end
					obj.End()
				end
			end
		end

		function _text.update(dt)
			if not (_text.ended) then
				for k,v in pairs(indextocommand) do
					if (char == k) then
						indextocommand[k] = nil
						executeCommand(v, _text)
					end
				end
				spc = _text.speed * dt
				timer = char < _text.content:len() and (timer + dt) or 0
				if (timer >= spc) then
					current = _text.content:sub(1, char)
					timer = timer - spc
					char = char + 1
				end
				if (char == _text.content:len()) then
					_text.End()
				end
			end
		end

		function _text.draw()
			lg.setColor(_text.color)
			lg.print(current, fonts[_text.font], _text.x, _text.y)
			lg.setColor(1, 1, 1, 1)
		end

		function _text.End()
			current = _text.content
			char = _text.content:len()
			_text.ended = true
		end

		function _text.SetColor(rgba)
			local r = bit.band(bit.rshift(rgba, 24), 255) / 255.0
			local g = bit.band(bit.rshift(rgba, 16), 255) / 255.0
			local b = bit.band(bit.rshift(rgba, 8), 255) / 255.0
			local a = bit.band(rgba, 255) / 255.0
			_text.color = {r, g, b, a}
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