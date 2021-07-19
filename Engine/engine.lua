local self = {}

local function on_fight()
	Fight.Start()
end

local function on_act()
	Act.Start()
end

local function on_item()
	Inventory.Start()
end

local function on_mercy()
	Mercy.Start()
end

function self.loadEngine()
	dialog_text = nil
	active_text = dialog_text

	buttons = {{id="fight", x=32, y=430, px=40, py=445, callback=on_fight},
			{id="act", x=185, y=430, px=193, py=445, callback=on_act},
			{id="item", x=345, y=430, px=353, py=445, callback=on_item},
			{id="mercy", x=500, y=430, px=508, py=445, callback=on_mercy}}

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
		local pressed = current_button == i
		local id = b.id .. "_" .. (pressed and 1 or 0)
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
	if (current_state == "MENUBATTLE") then
		Player.sprite.alpha = 1
	elseif (current_state == "BATTLEDIALOG") then
		Player.sprite.alpha = 0
	elseif (current_state == "ATTACKING") then
		Fight.update(dt)
	elseif (current_state == "DEFENDING") then
		Player.update()
	elseif (current_state == "DONE") then
		current_menu = "mods"
		self.unloadEngine()
		loadAllMods()
	end
	Texts.update(dt)
	Sprites.update(dt)
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
	if (current_state == "MENUBATTLE") then

		local b = current_button
		if Input.equals(key, "Right") then
			b = b + 1
		elseif Input.equals(key, "Left") then
			b = b - 1
		end
		SetAction(b)
		
		if Input.equals(key, "Confirm") then
			buttons[current_button].callback()
		end

	elseif (current_state == "ITEMMENU") then
	    Inventory.keypressed(key)
	elseif (current_state == "ACTMENU") then
		Act.keypressed(key)
	elseif (current_state == "MERCYMENU") then
		Mercy.keypressed(key)
	elseif (current_state == "FIGHTMENU" or current_state == "ATTACKING") then
		Fight.keypressed(key)
	elseif (current_state == "BATTLEDIALOG") then
		if (dialog_text.ended and Input.equals(key, "Confirm")) then
			State("ENEMYDIALOGUE")
		end
	end

	if (Input.equals(key, "Cancel")) then
		if (current_state:sub(-4) == "MENU") then
			if (current_state == "MERCYMENU") then
				Mercy.resetPage()
				SetAction(4)
			elseif (current_state == "ITEMMENU") then
				Inventory.resetPage()
				SetAction(3)
			elseif (current_state == "ACTMENU") then
				Act.resetPage()
				SetAction(2)
			elseif (current_state == "FIGHTMENU") then
				Fight.resetPage()
				SetAction(1)
			end
			BattleDialog(Encounter.encountertext)
			State("MENUBATTLE")	
		else
			active_text.End()
		end
	end
end

function SetAction(button)
	if (button == -1) then
		current_button = -1
	else
		current_button = math.clamp(button, 1, #buttons, true)
		Player.MoveTo(buttons[current_button].px, buttons[current_button].py)
	end
end

--TODO: MOVE TO MONSTER
function CheckMessage()
	BattleDialog("%ENEMYNAME%, ATK, DEF,\nCHECK MESSAGE")
end	

local function EnteringState(os, ns)
	Encounter.EnteringState(os, ns)
	if (ns == "ENEMYDIALOGUE") then
		SetAction(-1)
		Encounter.EnemyDialogueStarting()
	elseif (ns == "DEFENDING") then
		Encounter.EnemyDialogueEnding()
	elseif (ns == "MENUBATTLE" and os == "DEFENDING") then
		Encounter.DefenseEnding()
	elseif (ns == "ATTACKING") then
		Fight.AttackTarget()
	end
	--It's like an event listener
	--BD -> BM -> FM/AM/IM/MM
	--FM -> 		EDS -> DEFENDING
	--AM -> BD -> 	EDS -> DEFENDING
	--IM -> BD ->	EDS -> DEFENDING
	--MM -> BD/END 	...
end

function State(ns)
	EnteringState(current_state, ns)
	current_state = ns
end

function BattleDialog(text)
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
			insert = insert .. "* " .. t .. "\n"
		end
	end
	if dialog_text then
		dialog_text.SetText(insert, "uidialog")
	else
		dialog_text = CreateText(insert, "uidialog", 53, 269)
	end
	active_text = dialog_text
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

function CreateText(text, font, x, y, fpc)
	active_text = Texts.Create(text, font, x, y, fpc)
	return active_text
end

return self