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
		dialog_text.SetText("")
		self.texts[1] = CreateChoice("Spare", 1)
		self.texts[2] = CreateChoice("Flee", 3)
		self.choice = 1
		SelectChoice(self.choice)
	end

	function self.keypressed(key)
		if (key == "up") then
			self.choice = 1
		elseif (key == "down") then
			self.choice = 3
		end
		SelectChoice(self.choice)
		if (Input.equals(key, "Confirm")) then
			self.resetPage()
			if (self.choice == 1) then
				Encounter.HandleSpare()
			else
				Encounter.HandleFlee()
				State("DONE")
			end
		end
	end

	function self.resetPage()
		self.texts[1].Remove()
		self.texts[2].Remove()
	end

	return self
end)()