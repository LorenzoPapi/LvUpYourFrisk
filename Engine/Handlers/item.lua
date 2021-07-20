--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.items = {}
	self.texts = {}
	self.current = 1
	self.current_page = 1

	function self.Start()
		if (#self.items > 0) then
			State("ITEMMENU")
			BattleDialog("")
			self.current = 1
			self.current_page = 1
			self.drawPage()
			SelectChoice(1)
		end
	end

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

	function self.AddItem(name, t, callback, index)
		local _item = {}
		_item.name = name or ""
		_item.type = t or 0
		-- 0 is consumable, 1 is weapon, 2 is armor, 3 is not deleted
		_item.onuse = callback or defaultCallback(name, _item.type)
			
		if (index) then
			table.insert(self.items, index, _item)
		else
			table.insert(self.items, _item)
		end
	end

	function self.GetItem(index)
		return self.items[index]
	end

	function self.UseItem(index)
		self.GetItem(index).onuse()
	end

	function self.AddItems(items)
		for i=1,#items do
			local a = items[i]
			self.AddItem(a[1], a[2], a[3], a[4])
		end
	end

	function self.keypressed(k)
		if (Input.equals(k, "Confirm")) then
			self.resetPage()
			self.UseItem(self.current)
			if not (self.GetItem(self.current).type == 3) then
				table.remove(self.items, self.current)
			end
			self.current = 1
			return
		elseif (k == "left") then
			self.current = self.current - 1
		elseif (k == "right") then
			self.current = self.current + 1
		elseif (k == "up") then
			self.current = self.current - 2
		elseif (k == "down") then
			self.current = self.current + 2
		end
		self.current = math.clamp(self.current, 1, #self.items)

		local cur_page = math.ceil(self.current / 4)
		if not (cur_page == self.current_page) then
			self.current_page = cur_page
			self.redrawPage()
		end

		SelectChoice((self.current - 1) % 4 + 1)
	end

	function self.drawPage()
		for i=1,4 do
			local cur = i+4*(self.current_page-1)
			if self.GetItem(cur) then
			    self.texts[i] = CreateChoice(self.GetItem(cur).name, i)
			end
		end
		if (#self.items > 4) then
			table.insert(self.texts, CreateText("[instant]PAGE " .. self.current_page, "uidialog", 300, 350))
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
		table.clear(self.items)
		self.current = 1
		self.current_page = 1
	end

	return self
end)()