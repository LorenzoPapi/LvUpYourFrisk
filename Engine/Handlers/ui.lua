return (function()
	local self = {}

	local function onFight()
		Fight.Start()
	end

	local function onAct()
		Act.Start()
	end

	local function onItem()
		Inventory.Start()
	end

	local function onMercy()
		Mercy.Start()
	end

	local bdialog = nil
	local currenttexts = nil
	local action = 1

	function self.load()
		self.buttons = {{id="fight", x=32, y=430, px=40, py=445, onclick=onFight},
						{id="act", x=185, y=430, px=193, py=445, onclick=onAct},
						{id="item", x=345, y=430, px=353, py=445, onclick=onItem},
						{id="mercy", x=500, y=430, px=508, py=445, onclick=onMercy}}
		self.ui = {
			bg = CreateSprite("bg", 0, 0),
			name = CreateText("[instant]" .. Player.name, "uibattlesmall", 32, 402),
			lv = CreateText("[instant]LV  " .. Player.lv, "uibattlesmall", Player.name:len() > 6 and 193 or 149, 402),
			hpimage = CreateSprite("hp", Player.name:len() > 6 and 316 or 245, 405),
			maxhp = CreateSprite("px", Player.name:len() > 6 and 347 or 276, 400, 0, math.min(120, Player.maxhp * 1.2), 20),
			hp = CreateSprite("px", Player.name:len() > 6 and 347 or 276, 400, 0, math.max(0, Player.hp * 1.2), 20),
			hptext = CreateText("[instant]" .. Player.hp .. " / " .. Player.maxhp, "uibattlesmall", Player.name:len() > 6 and 385 or 314, 402)
		}
		self.ui.maxhp.SetColor(1, 0, 0)
		self.ui.hp.SetColor(1, 1, 0)

		for _,b in ipairs(self.buttons) do
			self.ui[b.id] = CreateSprite(b.id .. "_" .. 0, b.x, b.y)
		end
		SetAction(1)
	end

	function self.update(dt)
		for i,b in ipairs(self.buttons) do
			self.ui[b.id].Set(b.id .. "_" .. (action == i and 1 or 0))
		end
		self.ui.maxhp.Scale(math.min(120, Player.maxhp * 1.2), 20)
		self.ui.hp.Scale(math.max(0, Player.hp * 1.2), 20)
		self.ui.hptext.SetText("[instant]" .. Player.hp .. " / " .. Player.maxhp)
		self.ui.hptext.MoveTo(flag and 385 or 314 + self.ui.maxhp.xscale - 24, 402)
	end

	function self.SetAction(button)
		if (button == -1) then
			action = -1
		else
			if not (button == action) then
				Audio.PlaySound("move")
			end
			action = math.clamp(button, 1, #self.buttons, true)
			Player.MoveTo(self.buttons[action].px, self.buttons[action].py)
		end
	end

	function self.updateKey()
		if (GetCurrentState() == "MENUBATTLE") then
			if Input.IsDown("left") then
				SetAction(action - 1)
			elseif Input.IsDown("right") then
				SetAction(action + 1)
			elseif Input.IsDown(Input.Confirm) then
				self.buttons[action].onclick()
				Audio.PlaySound("confirm")
			end
		elseif (GetCurrentState() == "BATTLEDIALOG" and bdialog.ended and Input.IsDown(Input.Confirm)) then
			State("ENEMYDIALOGUE")
		end
	end

	function self.EndText()
		currenttexts.End()
	end

	local function insertStar(a)
		local newlines = {}
		local commands = {}
		local i = 0
		local inComm = false

		for c in a:gmatch(".") do
			if (c == "[") then
				inComm = not inComm
			elseif (c == "]") then
				inComm = false
			elseif (not inComm) then
				break
			end
			i = i + 1
		end
		return a:sub(0, i) .. "* " .. a:sub(i+1)
	end

	local function checkNewlines(t)
		local a = ""
		if not (t:find("\n", 0, true)) then
			a = insertStar(t) .. "\n"
		else
			for str in t:gmatch("[^\n]+") do
				a = a .. insertStar(str .. "\n")
			end
		end
		return a
	end

	function self.BattleDialog(text)
		local insert = ""
		if (text == "" or not text) then
			bdialog.SetText("", "uidialog")
			bdialog.End()
			return
		elseif (type(text) == "string") then
			insert = checkNewlines(text)
		elseif (type(text) == "table") then
			for _,t in ipairs(text) do
				insert = insert .. checkNewlines(t)
			end
		end
		if bdialog then
			bdialog.SetText(insert, "uidialog")
		else
			bdialog = CreateText(insert, "uidialog", 53, 269)
			bdialog.SetVoice("uifont")
		end
		self.SetCurrentText(bdialog)
		State("BATTLEDIALOG")
	end

	function self.CreateChoice(text, i)
		local x = 60
		local y = 270
		if (i%2==0) then
			x = 335
		end
		if (i%3==0 or i%4==0) then
			y = 300
		end
		return CreateText("[instant] " .. insertStar(text), "uidialog", x, y)
	end

	function self.updatePositions()
		local flag = Player.name:len() > 6
		self.ui.name.SetText("[instant]" .. Player.name)
		self.ui.lv.SetText("[instant]LV  " .. Player.lv)
		self.ui.lv.MoveTo(flag and 193 or 149, 402)
		self.ui.hpimage.MoveTo(flag and 316 or 245, 405)
		self.ui.maxhp.MoveTo(flag and 347 or 276, 400)
		self.ui.hp.MoveTo(flag and 347 or 276, 400)
	end

	function self.SetCurrentText(text)
		currenttexts = text
	end

	return self
end)()