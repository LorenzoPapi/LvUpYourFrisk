--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.acts = {}
	self.texts = {}
	self.current = 1
	self.current_page = 1

	function self.Start()
		State("ACTMENU")
		dialog_text.SetText("")
		self.current = 1
		self.current_page = 1
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

	function self.keypressed(k)
		if (Input.equals(k, "Confirm")) then
			self.resetPage()
			self.GetAct(self.current).onclick()
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
		self.current = math.clamp(self.current, 1, #self.acts)

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
			if self.GetAct(cur) then
			    self.texts[i] = CreateChoice(self.GetAct(cur).name, i)
			end
		end
		if (#self.acts > 4) then
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
		table.clear(self.acts)
		self.current = 1
		self.current_page = 1
	end

	return self
end)()