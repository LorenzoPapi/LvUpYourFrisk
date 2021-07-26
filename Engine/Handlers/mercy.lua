--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}
	self.choice = 1
	self.texts = {}

	function self.Start()
		State("MERCYMENU")
		BattleDialog("")
		local spare = false
		
		for i=1,#Encounter.enemies do
			if (Encounter.enemies[i].canspare) then
				spare = true
				break
			end
		end
		self.texts[1] = CreateChoice((spare and "[color:ffff00ff]" or "") .. "Spare", 1)

		if (Encounter.flee) then
			self.texts[2] = CreateChoice("Flee", 3)
		end
		self.choice = 1
		SelectChoice(self.choice)
	end

	local function flee()
		Encounter.HandleFlee()
		BattleDialog(Encounter.fleetexts[math.random(1, #Encounter.fleetexts)] .. "[w:20] [func:State,DONE]")
	end

	function self.updateKey()
		if Input.IsDown("up") then
			self.choice = 1
		elseif Input.IsDown("down") and Encounter.flee then
			self.choice = 3
		end
		SelectChoice(self.choice)
		if Input.IsDown(Input.Confirm) then
			Audio.PlaySound("confirm")
			self.resetPage()
			if (self.choice == 1) then
				Encounter.HandleSpare()
			elseif (Encounter.fleesuccess == false) then
				--ADD failFleeTexts
				BattleDialog("You tried to flee the battle...\n[w:30][w:10]You failed.")
			else
				if (Encounter.fleesuccess) then
					flee()
				elseif (Encounter.fleesuccess == nil) then
					--TODO: formula
					if (math.random(0, 1) % 2 == 0) then
						flee()
					else
						BattleDialog("You tried to flee the battle...\n[w:30]You failed.")
					end
				end
			end
		end
	end

	function self.resetPage()
		self.texts[1].Remove()
		if (Encounter.flee) then
			self.texts[2].Remove()
		end
	end

	return self
end)()