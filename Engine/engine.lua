return (function()
	local self = {}

	local currentstate = ""
	local turn = 1
	local enemyDialogues = {}

	function self.loadEngine()
		Arena.Rectangle(35, 253, 605, 387)
		Arena.load()
		Player.load()
		UI.load()
		BattleDialog(Encounter.encountertext)
		State("MENUBATTLE")
		Audio.PlayMusic(Encounter.music, true)
		Encounter.EncounterStarting()
	end

	function self.drawEngine()
		--TODO: add layers: layers can be called in order, bottom being called first and top being called last
		Sprites.draw()		
		Texts.draw()
		Arena.draw()
		Player.draw()
	end

	local function checkKeyInput()
		if (GetCurrentState() == "ITEMMENU") then
			Inventory.updateKey()
		elseif (GetCurrentState() == "ACTMENU" or GetCurrentState() == "ACTING") then
			Act.updateKey()
		elseif (GetCurrentState() == "MERCYMENU") then
			Mercy.updateKey()
		elseif (GetCurrentState() == "FIGHTMENU" or GetCurrentState() == "ATTACKING") then
			Fight.updateKey()
		elseif (GetCurrentState() == "ENEMYDIALOGUE") then
			if Input.IsDown(Input.Confirm) then
				for i=1,#enemyDialogues do
					if not (enemyDialogues[i].ended) then
						UI.SetCurrentText(enemyDialogues[i])
						break
					elseif (i == #enemyDialogues) then
						State("DEFENDING")
					end
				end
			end
		end

		if Input.IsDown(Input.Cancel) then
			if (GetCurrentState():sub(-4) == "MENU") then
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
				UI.EndText()
			end
		end
		UI.updateKey()
	end

	function self.updateEngine(dt)
		checkKeyInput()
		UI.update(dt)
		Audio.update(dt)
		Texts.update(dt)
		Sprites.update(dt)
		Arena.update(dt)
		Encounter.Update(dt)
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
	end

	function SetAction(button)
		UI.SetAction(button)
	end

	local function EnteringState(os, ns)
		if (ns == "ENEMYDIALOGUE") then
			SetAction(-1)
			BattleDialog("")
			Arena.Resize(Encounter.fightarena, 2)
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
			Arena.Resize(Encounter.fightarena, 3)
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
		UI.BattleDialog(text)
	end

	function CreateSprite(name, x, y, r, xscale, yscale, xpivot, ypivot)
		return Sprites.Create(name, x, y, r, xscale, yscale, xpivot, ypivot)
	end

	function CreateChoice(text, i)
		return UI.CreateChoice(text, i)
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
		local t = Texts.Create(text, font, x, y, fpc)
		UI.SetCurrentText(t)
		return t
	end

	return self
end)()