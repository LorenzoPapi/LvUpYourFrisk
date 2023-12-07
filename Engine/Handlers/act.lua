--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.acts = {}
	self.texts = {}
	self.current = 1
	self.page = 1

	function self.Start()
		State("ACTMENU")
		BattleDialog("")
		self.current = 1
		self.page = 1
		SelectChoice(1)
		self.drawPage()
	end

	local function defaultCallback(name)
		return function ()
			BattleDialog("You selected " .. name .. ".\nIt did nothing.")
		end
	end

	function self.AddAct(name, callback, index)
		local _act = {}
		_act.name = name or ""
		_act.onclick = callback or defaultCallback(name)

		if (index) then
			table.insert(self.acts, index, _act)
		else
			table.insert(self.acts, _act)
		end
	end

	function self.GetAct(index)
		return self.acts[index]
	end

	function self.AddActs(acts)
		for i=1,#acts do
			local a = acts[i]
			self.AddAct(a[1], a[2], a[3])
		end
	end

	function self.updateKey()
		if Input.IsDown(Input.Confirm) then
			Audio.PlaySound("confirm")
			if (GetCurrentState() == "ACTMENU") then
				self.Reset()
				State("ACTING")
				local enemy = Encounter.enemies[self.current]
				if (enemy.cancheck) then
					self.AddAct("Check", function () BattleDialog(enemy.name .. " " .. enemy.atk .. " ATK " .. enemy.def .. " DEF\n" .. enemy.check) end)
				end
				self.AddActs(enemy.acts)
				self.redrawPage()
			elseif (GetCurrentState() == "ACTING") then
				self.GetAct(self.current).onclick()
				self.current = 1
				self.resetPage()
			end
			return
		elseif Input.IsDown("left") then
			self.current = self.current - 1
		elseif Input.IsDown("right") then
			self.current = self.current + 1
		elseif Input.IsDown("up") then
			self.current = self.current - 2
		elseif Input.IsDown("down") then
			self.current = self.current + 2
		end
		self.current = math.clamp(self.current, 1, GetCurrentState() == "ACTMENU" and #Encounter.enemies or #self.acts)

		local newpage = math.ceil(self.current / 4)
		if newpage ~= self.page then
			self.page = newpage
			self.redrawPage()
		end

		SelectChoice((self.current - 1) % 4 + 1)
	end

	function self.drawPage()
		if (GetCurrentState() == "ACTMENU") then
			for i=1,4 do
				local cur = i+4*(self.page-1)
				if Encounter.enemies[i] then
					self.texts[i] = CreateChoice((Encounter.enemies[i].canspare and "[color:ffff00ff]" or "") .. Encounter.enemies[i].name, i)
				end
			end
			if (#Encounter.enemies > 4) then
				table.insert(self.texts, CreateText("[instant]PAGE " .. self.page, "uidialog", 300, 350))
			end
		elseif (GetCurrentState() == "ACTING") then
			for i=1,4 do
				local cur = i+4*(self.page-1)
				if self.GetAct(cur) then
					self.texts[i] = CreateChoice(self.GetAct(cur).name, i)
				end
			end
			if (#self.acts > 4) then
				table.insert(self.texts, CreateText("[instant]PAGE " .. self.page, "uidialog", 300, 350))
			end
		end
	end

	function self.redrawPage()
		self.resetPage()
		self.drawPage()
	end

	function self.resetPage()
		for i=1,#self.texts do
			self.texts[i].Remove()
		end
	end

	function self.Reset()
		table.clear(self.acts)
		self.current = 1
		self.page = 1
		SelectChoice(self.current)
	end

	return self
end)()