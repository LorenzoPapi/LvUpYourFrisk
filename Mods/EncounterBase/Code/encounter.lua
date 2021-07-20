return (function()
	local self = require("Engine/encounterbase")

	--self.enemies = {"Luigi", "Mario", "Peach", "Cherry", "....?", "...", "$!", "OwO", "Hidden!"}
	self.enemies = {"poseur"}
	self.encountertext = {"Poseur strikes a pose!\nHis moves are too much for me!"}
	self.flee = true
	self.fightarena = {200, 253, 100, 387, 500, 387}
	
	function self.EncounterStarting()
		CreateSprite("player")
		--Act.AddAct("Check", CheckMessage)
		Inventory.AddItems({{"Shotgun", 1}, {"Butterscotch Pie"}, {"Instant Noodles"}, {"CHOCOLATE"}, {"L O V E", 3}, {"Tem armor", 2}})
		Inventory.AddItem("Corn flakes")
		Inventory.AddItem("Sea tea")
		Inventory.AddItem("<ERROR>", 3)
		Inventory.AddItem("INITIO", 3)
		Inventory.AddItem("FINAL FINALIS", 3)
		--Arena.Regular(-130, 320, 240, 16)
	end

	function self.EnemyDialogueStarting()
	end

	function self.EnemyDialogueEnding()
	end

	function self.DefenseEnding()
		self.encountertext = self.RandomEncounterText()
	end

	function self.HandleSpare()
		BattleDialog("Overridden!")
	end

	function self.HandleFlee()
		--TODO: default callback
	end

	function self.EnteringState(os, ns)
	end

	function self.Update(dt)
		if (GetCurrentState() == "ENEMYDIALOGUE" or GetCurrentState() == "DEFENDING") then
			Arena.RotateCWBy(love.timer.getDelta() * 100)
			Arena.SetColor(love.timer.getTime() * math.random(1, 100))
		end
	end

	function self.BeforeDeath()
	end
	
	return self
end)()