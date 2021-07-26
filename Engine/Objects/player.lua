return (function()

	--TODO: hp shifting whatever the fuck it is

	local allowplayerdef = false
	local invulTimer = 0
	local exp = 0
	local exptable = { 10, 30, 70, 120, 200, 300, 500, 800, 1200, 1700, 2500, 3500, 5000, 7000, 10000, 15000, 25000, 50000, 99999, 100000 }

	local self = createSpecialTable({
		x = 0,
		y = 0,
		sprite = CreateSprite("player"),
		hp = 20,
		maxhp = 20,
		atk = 10,
		weapon = "Stick",
		weaponatk = 0,
		def = 10,
		armor = "Bandage",
		armordef = 0,
		name = "FRISK",
		lv = 1,
		lastenemychosen = -1,
		lasthitmultiplier = -1,
		ishurting = false,
		ismoving = false,
		--Vertices defining the box of the player, the more vertex the more accurate, but performance might get worse (I guess?)
		--We consider the pivot to be in the TOP-LEFT of the sprite
		box = {{2, 0}, {0, 2}, {0, 9}, {6, 15}, {9, 15}, {15, 9}, {15, 2}, {13, 0}} 
	}, function(proxy, k, v)
		if not table.containsValue(proxy, debug.getinfo(3, "f").func) and (k == "x" or k == "y" or k == "maxhpshift" or k == "weapon" or k == "weaponatk" or k == "armor" or k == "armordef" or k == "lastenemychosen" or k == "lasthitmultiplier" or k == "ishurting" or k == "ismoving") then
			error("You cannot set value of " .. k .. " because it's readonly")
		elseif k == "name" or k == "lv" or k == "maxhp" or k == "hp"then
			if k == "name" then
				proxy[k] = v:sub(1, 9)
			elseif k == "lv" then
				local newlv = math.clamp(v, 1, 99)
				proxy.maxhp = 16 + 4 * newlv
				proxy.atk = 8 + 2 * newlv
				proxy.def = 10 + math.floor((newlv - 1) / 4)
				proxy[k] = newlv
				exp = newlv == 1 and 0 or (newlv <= 20 and exptable[newlv - 1] or 99999)
				proxy.maxhp = newlv >= 20 and proxy.maxhp + 3 or proxy.maxhp
				proxy.hp = proxy.hp > proxy.maxhp and proxy.maxhp or proxy.hp
			end
			UI.updatePositions()
		end
	end)

	self.sprite.SetColor(1, 0, 0)

	function self.Hurt(value, invul, ignoredef, playsound)
		if self.ishurting then return end
		value = value or 3
		invul = invul or 1.7
		playsound = playsound or true

		if not ignoredef and allowplayerdef and value > 0 then
            value = value + 2 - math.floor((self.def + self.armordef) / 5)
            value = value <= 0 and 1 or value
        end
        if value == 0 and invul == 0 then
        	invulTimer = 0
        	return
        end
        if value >= 0 and (invulTimer <= 0 or invul < 0) then
			if playsound then Audio.PlaySound("hurtsound") end
			if invul >= 0 then invulTimer = invul end
		elseif value < 0 and playsound then
			Audio.PlaySound("healsound")
        end
		
		self.ForceHP(self.hp - value)
	end

	function self.Heal(value)
		self.Hurt(-value, 0)
	end

	function self.Move(x, y)
		self.MoveTo(self.x + x, self.y + y)
	end

	function self.MoveTo(x, y)
		self.x = x
		self.y = y
		self.sprite.MoveTo(x, y)
	end

	function self.ForceHP(newhp)
		local limit = self.maxhp * 1.5
		if newhp <= 0 then error("NYI") end
		self.hp = newhp > limit and limit or newhp
	end

	function self.ResetStats(resetMHP, resetATK, resetDEF)
		resetMHP = resetMHP or true
		resetATK = resetATK or true
		
		self.maxhp = resetMHP and 16 + 4 * self.lv or self.maxhp
		self.atk = resetATK and 8 + 2 * self.lv or self.atk
		self.def = resetDEF and 10 + math.floor((self.lv - 1) / 4) or self.def
	end

	function self.draw()
		love.graphics.setColor(1, 1, 1, self.sprite.alpha)
		local a = {}
		for i=1,#self.box do
			table.insert(a, self.x + self.box[i][1])
			table.insert(a, self.y + self.box[i][2])
		end	
		love.graphics.polygon("line", a)
		love.graphics.setColor(1, 1, 1, 1)
	end

	function self.update(dt)
		self.ishurting = invulTimer > 0
		if self.ishurting then
			invulTimer = invulTimer - dt
			self.sprite.alpha = (invulTimer % 0.18 < 0.09 or invulTimer <= 0) and 1 or 0
		end

		if GetCurrentState() == "DEFENDING" then
			local mul = Input.GetKey(Input.Cancel) > 0 and 1 or 2
			local x = self.x
			local y = self.y
			if Input.GetKey(Input.Up) > 0 then
				y = y - mul
			end
			if Input.GetKey(Input.Down) > 0 then
				y = y + mul
			end
			if Input.GetKey(Input.Left) > 0 then
				x = x - mul
			end
			if Input.GetKey(Input.Right) > 0 then
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
	end

	function AllowPlayerDef(value)
		allowplayerdef = value
	end

	return self
end)()