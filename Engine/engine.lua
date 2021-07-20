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

	local currentstate = ""
	local turn = 1
	local enemyDialogues = {}
	local dialogtext = nil
	local currenttext = nil

	function self.loadEngine()
		buttons = {{id="fight", x=32, y=430, px=40, py=445, onclick=onFight},
			{id="act", x=185, y=430, px=193, py=445, onclick=onAct},
			{id="item", x=345, y=430, px=353, py=445, onclick=onItem},
			{id="mercy", x=500, y=430, px=508, py=445, onclick=onMercy}}

		Arena.Rectangle(35, 253, 605, 387)
		Arena.load()
		Player.load()

		BattleDialog(Encounter.encountertext)
		State("MENUBATTLE")
		SetAction(1)
		Encounter.EncounterStarting()
	end

	function self.drawEngine()
		lg.draw(sprites["bg"], 0, 0)

		for i,b in ipairs(buttons) do
			local id = b.id .. "_" .. (action == i and 1 or 0)
			lg.draw(sprites[id], b.x, b.y)
		end

		lg.print(Player.name, fonts["uibattlesmall"], 32, 402)
		lg.print("LV  " .. Player.lv, fonts["uibattlesmall"], Player.name:len() > 6 and 193 or 149, 402)
		lg.draw(sprites["hp"], Player.name:len() > 6 and 316 or 245, 405)
		lg.setColor(1, 0, 0)
		lg.draw(sprites["px"], Player.name:len() > 6 and 347 or 276, 400, 0, math.min(120, Player.maxhp * 1.2), 20)
		lg.setColor(1, 1, 0)
		lg.draw(sprites["px"], Player.name:len() > 6 and 347 or 276, 400, 0, math.max(0, Player.hp * 1.2), 20)
		lg.setColor(1, 1, 1)
		lg.print(Player.hp .. " / " .. Player.maxhp, fonts["uibattlesmall"], Player.name:len() > 6 and 385 or 314, 402)

		Sprites.draw()
		--TODO: add layers: layers can be called in order, bottom being called first and top being called last
		Texts.draw()
		Arena.draw()
		Player.draw()
	end

	function self.updateEngine(dt)
		if (GetCurrentState() == "MENUBATTLE") then
			Player.sprite.alpha = 1
		elseif (GetCurrentState() == "BATTLEDIALOG") then
			Player.sprite.alpha = 0
		elseif (GetCurrentState() == "ATTACKING") then
			Fight.update(dt)
		elseif (GetCurrentState() == "DEFENDING") then
			Player.update()
		elseif (GetCurrentState() == "DONE") then
			unloadCurrentMod()
		end
		Texts.update(dt)
		Sprites.update(dt)
		Arena.update(dt)
		Encounter.Update(dt)
	end

	function self.unloadEngine()
		table.clear(sprites)
		table.clear(fonts)
		Sprites.Reset()
		Texts.Reset()
		Inventory.Reset()
		Act.Reset()
		Arena.Reset()
		loadResourcesFromDirectory("Default/")
	end

	function self.keypressed(key, scancode, isrepeat)
		if (GetCurrentState() == "MENUBATTLE") then
			local b = action
			if Input.equals(key, "Right") then
				b = b + 1
			elseif Input.equals(key, "Left") then
				b = b - 1
			end
			SetAction(b)

			if Input.equals(key, "Confirm") then
				buttons[action].onclick()
			end
		elseif (GetCurrentState() == "ITEMMENU") then
			Inventory.keypressed(key)
		elseif (GetCurrentState() == "ACTMENU" or GetCurrentState() == "ACTING") then
			Act.keypressed(key)
		elseif (GetCurrentState() == "MERCYMENU") then
			Mercy.keypressed(key)
		elseif (GetCurrentState() == "FIGHTMENU" or GetCurrentState() == "ATTACKING") then
			Fight.keypressed(key)
		elseif (GetCurrentState() == "ENEMYDIALOGUE") then
			for i=1,#enemyDialogues do
				if not (enemyDialogues[i].ended) then
					currenttext = enemyDialogues[i]
					break
				elseif (i == #enemyDialogues) then
					State("DEFENDING")
				end
			end
		elseif (GetCurrentState() == "BATTLEDIALOG") then
			if (dialogtext.ended and Input.equals(key, "Confirm")) then
				State("ENEMYDIALOGUE")
			end
		end

		if (Input.equals(key, "Cancel")) then
			if (currentstate:sub(-4) == "MENU") then
				if (GetCurrentState() == "MERCYMENU") then
					Mercy.resetPage()
					SetAction(4)
				elseif (GetCurrentState() == "ITEMMENU") then
					Inventory.resetPage()
					SetAction(3)
				elseif (GetCurrentState() == "ACTMENU") then
					Act.resetPage()
					SetAction(2)
				elseif (GetCurrentState() == "FIGHTMENU") then
					Fight.resetPage()
					SetAction(1)
				end
				BattleDialog(Encounter.encountertext)
				State("MENUBATTLE")
			elseif (GetCurrentState() == "ACTING") then
				Act.Reset()
				State("ACTMENU")
				Act.redrawPage()
			else
				currenttext.End()
			end
		end
	end

	function SetAction(button)
		if (button == -1) then
			action = -1
		else
			action = math.clamp(button, 1, #buttons, true)
			Player.MoveTo(buttons[action].px, buttons[action].py)
		end
	end

	--TODO: MOVE TO MONSTER
	function CheckMessage()
		BattleDialog("%ENEMYNAME%, ATK, DEF,\nCHECK MESSAGE")
	end	

	local function EnteringState(os, ns)
		if (ns == "ENEMYDIALOGUE") then
			SetAction(-1)
			BattleDialog("")
			Arena.Resize(Encounter.fightarena)
			Encounter.EnemyDialogueStarting()
			for i=1,#Encounter.enemies do
				local enemy = Encounter.enemies[i]
				if (#enemy.currentdialogue == 0) then
					enemy.currentdialogue = {enemy.randomdialogue[math.random(1, #enemy.randomdialogue)]}
				end
				table.insert(enemyDialogues, CreateText(enemy.currentdialogue, enemy.font, 320, 240))
				table.clear(enemy.currentdialogue)
			end
		elseif (ns == "DEFENDING" and os == "ENEMYDIALOGUE") then
			Player.sprite.alpha = 1
			for i=1,#enemyDialogues do
				enemyDialogues[i].Remove()
			end
			table.clear(enemyDialogues)
			Encounter.EnemyDialogueEnding()
		elseif (ns == "MENUBATTLE" and os == "DEFENDING") then
			Encounter.DefenseEnding()
			turn = turn + 1
			BattleDialog(Encounter.encountertext)
		elseif (ns == "ATTACKING") then
			Fight.AttackTarget()
		end
		Encounter.EnteringState(os, ns)
		--It's like an event listener
		--BD -> BM -> FM/AM/IM/MM
		--FM -> 		EDS -> DEFENDING
		--AM -> BD -> 	EDS -> DEFENDING
		--IM -> BD ->	EDS -> DEFENDING
		--MM -> BD/END 	...
	end

	function State(ns)
		local os = currentstate
		currentstate = ns
		EnteringState(os, currentstate)
	end

	function BattleDialog(text)
		if (text == "" or not text) then
			dialogtext.SetText("", "uidialog")
			return
		end
		local insert = text	
		if (type(text) == "string") then
			if not (text:find("\n", 0, true)) then
				insert = "* " .. text .. "\n"
			else
				insert = ""
				for str in text:gmatch("[^\n]+") do
					insert = insert .. "* " .. str .. "\n"
				end
			end
		elseif (type(text) == "table") then
			insert = ""
			for _,t in ipairs(text) do
				if not (t:find("\n", 0, true)) then
					insert = insert .. "* " .. t .. "\n"
				else
					for str in t:gmatch("[^\n]+") do
						insert = insert .. "* " .. str .. "\n"
					end
				end
			end
		end
		if dialogtext then
			dialogtext.SetText(insert, "uidialog")
		else
			dialogtext = CreateText(insert, "uidialog", 53, 269)
		end
		currenttext = dialogtext
		State("BATTLEDIALOG")
	end

	function CreateSprite(name, x, y, r, xscale, yscale, xpivot, ypivot)
		return Sprites.Create(name, x, y, r, xscale, yscale, xpivot, ypivot)
	end

	function CreateChoice(text, i)
		--index can be from 1-4
		local x = 70
		local y = 270
		if (i%2==0) then
			x = 345
		end
		if (i%3==0 or i%4==0) then
			y = 300
		end
		return CreateText("[instant]* " .. text, "uidialog", x, y)
	end

	function SelectChoice(i)
		local px = 45 --selection - 25
		local py = 278  --selection + 8
		if (i%2==0) then
			px = 320
		end
		if (i%3==0 or i%4==0) then
			py = 308
		end
		Player.MoveTo(px, py)
	end

	function GetCurrentState()
		return currentstate
	end

	function CreateText(text, font, x, y, fpc)
		currenttext = Texts.Create(text, font, x, y, fpc)
		return currenttext
	end

	return self
end)()