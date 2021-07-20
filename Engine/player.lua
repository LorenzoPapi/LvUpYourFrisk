return (function()
	local self = {}

	self.x = 0
	self.y = 0
	--Vertices defining the box of the player, the more vertex the more accurate, but performance might get worse (I guess?)
	--We consider the pivot to be in the TOP-LEFT of the sprite
	self.box = {{2, 0}, {0, 2}, {0, 9}, {6, 15}, {9, 15}, {15, 9}, {15, 2}, {13, 0}}
	self.name = "FRISK"
	self.maxhp = 20
	self.hp = self.maxhp
	self.lv = 1
	self.weapon = "Stick"
	self.armor = "E"
	self.atk = 0
	self.def = 0

	function self.load()
		self.sprite = CreateSprite("player", self.x, self.y)
		self.sprite.SetColor(1, 0, 0)
		--self.sprite.SetAnimation({"player", "player1", "player2", "player3"}, 1/10, "loop")
		if (self.name:len() > 9) then
			self.name = self.name:sub(9)
		end
	end

	function self.MoveTo(x, y)
		self.x = x
		self.y = y
		self.sprite.MoveTo(x, y)
	end

	function self.draw()
		local a = {}
		for i=1,#self.box do
			table.insert(a, self.x + self.box[i][1])
			table.insert(a, self.y + self.box[i][2])
		end	
		love.graphics.polygon("line", a)
	end

	function self.update()
		local isDown = Input.isDown
		local mul = isDown("Cancel") and 1 or 2
		local x = self.x
		local y = self.y
		if isDown("Up") then
			y = y - mul
		end
		if isDown("Down") then
			y = y + mul
		end
		if isDown("Left") then
			x = x - mul
		end
		if isDown("Right") then
			x = x + mul
		end

		for i=1,#self.box do
			local p = self.box[i]
			if not (Arena.IsInside(x+p[1],y+p[2])) then
				break
			elseif i == #self.box then
				self.MoveTo(x, y)
			end
		end
	end

	return self
end)()