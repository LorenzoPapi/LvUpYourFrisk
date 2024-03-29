--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.items = {}
	self.texts = {}
	self.current = 1
	self.page = 1

	local function defaultCallback(name, t)
		if (t == 0) then
			return function()
				BattleDialog("You ate the " .. name .. ".\nYou recovered 0 HP.")
			end
		elseif (t == 1) then 
			return function()
				BattleDialog("You equipped the " .. name .. ".\nYou now have +0 ATK.")
			end
		elseif (t == 2) then
			return function() 
				BattleDialog("You equipped the " .. name .. ".\nYou now have +0 DEF.")
			end
		else
			return function()
				BattleDialog("You used the " .. name .. ".\nThis item won't be deleted.")
			end
		end
	end

	function self.AddItem(name, t, callback, index)
		local _item = {}
		_item.name = name or ""
		_item.type = t or 0
		-- 0 is consumable, 1 is weapon, 2 is armor, 3+ is not deleted
		_item.onuse = callback or defaultCallback(name, _item.type)
			
		if (index) then
			table.insert(self.items, index, _item)
		else
			table.insert(self.items, _item)
		end
	end

	function self.RemoveItem(index)
		table.remove(self.items, index)
	end

	function self.GetItem(index)
		return self.items[index]
	end

	function self.UseItem(index)
		self.GetItem(index).onuse()
	end

	function self.SetItem(item, index)
		self.items[index] = item
	end

	function self.AddItems(items)
		for i=1,#items do
			local a = items[i]
			self.AddItem(a[1], a[2], a[3], a[4])
		end
	end

	function self.SetStat(amount)
		local item = self.GetItem(current)
		if (item.type == 1) then
			Player.weapon = item.name
			Player.atk = amount
		elseif (item.type == 2) then
			Player.armor = item.name
			Player.def = amount
		end
	end

	function self.Start()
		if (#self.items > 0) then
			State("ITEMMENU")
			BattleDialog("")
			self.current = 1
			self.page = 1
			self.drawPage()
			SelectChoice(1)
		end
	end

	function self.updateKey()
		if Input.IsDown(Input.Confirm) then
			Audio.PlaySound("confirm")
			self.resetPage()
			self.UseItem(self.current)
			if self.GetItem(self.current).type ~= 3 then
				table.remove(self.items, self.current)
			end
			self.current = 1
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
		self.current = math.clamp(self.current, 1, #self.items)

		local newpage = math.ceil(self.current / 4)
		if newpage ~= self.page then
			self.page = newpage
			self.redrawPage()
		end

		SelectChoice((self.current - 1) % 4 + 1)
	end

	function self.drawPage()
		for i=1,4 do
			local cur = i+4*(self.page-1)
			if self.GetItem(cur) then
				self.texts[i] = CreateChoice(self.GetItem(cur).name, i)
			end
		end
		if (#self.items > 4) then
			table.insert(self.texts, CreateText("[instant]PAGE " .. self.page, "uidialog", 300, 350))
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

	return self
end)()