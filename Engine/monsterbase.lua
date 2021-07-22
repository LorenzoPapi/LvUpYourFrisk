--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.acts = {}
	self.name = ""
	self.randomdialogue = {}
	self.currentdialogue = {}
	self.font = "monster"
	self.cancheck = true
	self.atk = 0
	self.def = 0
	self.check = ""
	self.canspare = false

	--NYI
	self.comments = {}
	self.defensemisstext = ""
	self.noattackmisstext = ""
	self.isactive = true
	self.sprite = ""
	self.monstersprite = nil
	self.dialogbubble = ""
	self.dialogueprefix = ""
	self.maxhp = 0
	self.hp = self.maxhp
	self.xp = 0
	self.gold = 0
	self.unkillable = false
	self.posx = 0
	self.posy = 0
	self.voice = ""
	
	function self.HandleAttack(d)
	end

	function self.OnDeath()
	end

	function self.OnSpare()
	end

	function self.BeforeDamageCalculation()
	end

	function self.BeforeDamageValues(d)
	end

	return self
end)()