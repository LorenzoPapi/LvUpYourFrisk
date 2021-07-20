return (function()
	local self = require("Engine/encounterbase")

	self.enemies = {"Luigi", "Mario", "Peach", "Cherry", "....?", "...", "$!", "OwO", "Hidden!"}
	self.encountertext = {"Poseur strikes a pose!", "YES PLEASE WORK"}
	self.arenasize = {}
	
	function self.EncounterStarting()
		CreateSprite("player")
		Act.AddAct("Check", CheckMessage)
		Act.AddActs({{"Defending", function() State("DEFENDING") end}, {"ACT2"}, {"ACT3"}, {"ACT4?"}})
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
	end

	function self.HandleSpare()
		BattleDialog("Overridden!")
	end

	function HandleFlee()
		--TODO: default callback
	end

	function self.EnteringState(os, ns)
		if (ns == "DEFENDING") then
			
		end
	end

	function self.Update(dt)
		Arena.RotateCWBy(love.timer.getDelta() * 100)
		--Arena.SetColor(love.timer.getTime() * math.random(1, 100))
	end

	function self.BeforeDeath()
	end
	
	return self
end)()