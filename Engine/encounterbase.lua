--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.enemies = {}
	self.encountertext = ""
	self.flee = true
	self.fleesuccess = nil
	self.fleetexts = {"You escaped the fight.", "I've better things to do...", "Stop bothering me.", "I'm outta here."}
	self.unescape = false
	self.fightarena = {}
	
	--NYI
	self.music = ""
	self.nextwaves = {}
	self.wavetimer = 4.0
	self.enemypositions = {}
	self.revive = false
	self.deathtext = {}
	self.deathmusic = ""
	self.Wave = {}

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

	function self.HandleFlee()
		State("DONE")
	end

	function self.EnteringState(os, ns)
	end

	function self.Update(dt)
	end

	function self.RandomEncounterText()
		local enemy = self.enemies[math.random(1, #self.enemies)]
		return enemy.comments[math.random(1, #enemy.comments)]
	end

	--NYI
	function self.BeforeDeath()
	end
	
	return self
end)()