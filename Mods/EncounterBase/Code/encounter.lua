return (function()
	local self = require("Engine/Defaults/encounterbase")

	--self.enemies = {"Luigi", "Mario", "Peach", "Cherry", "....?", "...", "$!", "OwO", "Hidden!"}
	self.enemies = {"poseur"}
	self.encountertext = {"Poseur strikes a pose!\nHis moves are too much for me!"}
	self.fleesuccess = true
	self.flee = true
	self.fightarena = {	320, 50, 
						200, 300, 
						280, 400,
						400, 200 }
	
	function self.EncounterStarting()
		CreateSprite("player")
		Inventory.AddItems({{"Shotgun", 1}, {"Butterscotch Pie"}, {"Instant Noodles"}, {"CHOCOLATE"}, {"L O V E", 3}, {"Tem armor", 2}})
		Inventory.AddItem("Corn flakes")
		Inventory.AddItem("Sea tea")
		Inventory.AddItem("<ERROR>", 3)
		Inventory.AddItem("INITIO", 3)
		Inventory.AddItem("FINAL FINALIS", 3)
		local file = Misc.OpenFile("README.md")
		file.Write("First line\nSecond line\n\nForth Line")
		file.ReplaceLine(3, "Third??")
		file.Copy("README.bak", true)
		file.Write("REPLACED!")
		file.Move("moved.bak")
		file.Write("MOVED!")
		Audio.Stop(self.music)
		Player.lv = 10
		--Arena.Ellipse(100, 85, 320, 240)
		--Arena.Regular(-130, 320, 240, 16)
		--Arena.Polygon({35, 253, 35, 387, 605, 387, 605, 200, 300, 200, 400, 300}, true)
	end

	function self.EnemyDialogueStarting()
	end

	function self.EnemyDialogueEnding()
		--Player.MoveTo(320, 240)
		self.fightarena = regularVertices(100, 320, 240, 12)
	end

	function self.DefenseEnding()
		self.encountertext = self.RandomEncounterText()
	end

	function self.HandleSpare()
		BattleDialog("Overridden!")
	end

	function self.HandleFlee()
		BattleDialog("Overridden!")
	end

	function self.EnteringState(os, ns)
	end

	local a = 0

	function self.Update(dt)
		Arena.Rotate(a) --* (math.random(0, 1) == 1 and -1 or 1)
		--Misc.MoveWindow(math.cos(Time.frameCount) * 10, math.sin(Time.frameCount) * 10)
		if (GetCurrentState() == "ENEMYDIALOGUE" or GetCurrentState() == "DEFENDING") then
			--Arena.RotateCWBy(5)
			--Arena.SetColor(love.timer.getTime() * math.random(1, 100))
		end
		a = a + 0.5
	end

	function self.BeforeDeath()
	end
	
	return self
end)()