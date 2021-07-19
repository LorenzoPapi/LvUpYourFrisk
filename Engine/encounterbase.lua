--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.enemies = {}
	self.music = ""
	self.encountertext = ""
	self.enemypositions = {}
	self.arenasize = {}

	function self.EncounterStarting()
	end

	function self.EnemyDialogueStarting()
	end

	function self.EnemyDialogueEnding()
	end

	function self.DefenseEnding()
	end

	function self.HandleSpare()
		BattleDialog("You cannot spare the enemy yet.\n[w:30]Wait for the name to be yellow.")
	end

	function HandleFlee()
		--TODO: default callback
	end

	function self.EnteringState(os, ns)
	end

	function self.Update(dt)
	end

	function self.BeforeDeath()
	end
	
	return self
end)()