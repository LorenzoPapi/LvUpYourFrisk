return (function()

	local self = {
		Confirm = 	{"z", "return"},
		Cancel 	= 	{"x", "lshift", "rshift"},
		Menu 	= 	{"c", "lctrl"},
		Up 		=	{"w", "up"},
		Left 	=	{"a", "left"},
		Right 	= 	{"s", "right"},
		Down 	=	{"d", "down"};

		MousePosX = 0,
		MousePosY = 0
		--TODO: better mouse handling
	}

	local keys = {}

	local function GetState(key)
		if (love.keyboard.isDown(key)) then
			if (keys[key] == 2) then
				return 2
			else
				keys[key] = 2
				return 1
			end
		elseif keys[key] == -1 then
			keys[key] = nil
			return -1
		end
		return 0
	end

	function self.keyreleased(key, scancode)
		keys[key] = -1
	end
	
	function self.GetKey(key)
		if type(key) == "table" then
			local r = 0
			for i=1,#key do
				r = GetState(key[i])
				if r ~= 0 then
					break
				end
			end
			return r
		end
		return GetState(key)
	end

	function self.IsDown(key)
		return self.GetKey(key) == 1
	end

	function self.update(dt)
		self.MousePosX, self.MousePosY = love.mouse.getPosition()
	end

	return self
end)()