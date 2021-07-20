return (function()
	local self = require("Engine/monsterbase")

	self.acts = {{"Defending", function() State("DEFENDING") end}, {"ACT2"}, {"ACT3"}, {"ACT4?"}}
	self.name = "Poseur!"
	self.randomdialogue = {"Random!", "Wow", "Ok what is this??"}
	--self.currentdialogue = {"Current"}
	--self.font = "uidialog"

	return self
end)()