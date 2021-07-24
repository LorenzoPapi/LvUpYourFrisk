--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.texts = {}
	self.current = 1
	self.page = 1
	self.xbar = 595
	local bar = nil
	local hit = false

	function self.Start()
		State("FIGHTMENU")
		BattleDialog("")
		self.current = 1
		self.page = 1
		SelectChoice(1)
		self.drawPage()
	end

	function self.updateKey()
		if (Input.GetKey(Input.Confirm) == 1) then
			if (GetCurrentState() == "FIGHTMENU") then
				Audio.PlaySound("confirm")
				self.resetPage()
				self.current = 1
				State("ATTACKING")
			elseif (GetCurrentState() == "ATTACKING") then
				bar.SetAnimation({"fight_bar_0", "fight_bar_1"}, 1/12)
				hit = true
			end
			return
		elseif Input.GetKey("left") == 1 then
			self.current = self.current - 1
		elseif Input.GetKey("right") == 1 then
			self.current = self.current + 1
		elseif Input.GetKey("up") == 1 then
			self.current = self.current - 2
		elseif Input.GetKey("down") == 1 then
			self.current = self.current + 2
		end
		self.current = math.clamp(self.current, 1, #Encounter.enemies)

		local newpage = math.ceil(self.current / 4)
		if not (newpage == self.page) then
			self.page = newpage
			self.redrawPage()
		end

		SelectChoice((self.current - 1) % 4 + 1)
	end

	function self.drawPage()
		for i=1,4 do
			local cur = i+4*(self.page-1)
			if Encounter.enemies[cur] then
				self.texts[i] = CreateChoice((Encounter.enemies[cur].canspare and "[color:ffff00ff]" or "") .. Encounter.enemies[cur].name, i)
			end
		end
		if (#Encounter.enemies > 4) then
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

	function self.SetTarget(i)
		self.current = i
	end

	function self.update(dt)
		if (not hit and self.xbar > 30) then
			bar.Move(-10, 0)
			self.xbar = bar.x
		end
	end

	function self.AttackTarget()
		Player.sprite.alpha = 0
		local target = CreateSprite("fight_target", 37 + 10, 255 + 7.5)
		bar = CreateSprite("fight_bar_0", 595, 255)
	end

	return self
end)()