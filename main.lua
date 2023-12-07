--might remove if I feel like it
require("utils")
lg = love.graphics
local menu = "main"
local mod = 1
local mods = {}
local previews = {}
local modName = ""
local soundext = {".wav", ".mp3", ".ogg"}
local noreload = {"input", "time", "misc", "discord"}

local function forAllFilesIn(directory, callback)
	local dirs = {}
	table.insert(dirs, directory)
	for _,d in pairs(dirs) do
		for _,f in pairs(love.filesystem.getDirectoryItems(d)) do
			callback(d, f)
			if love.filesystem.getInfo(d..f, "directory") then
				table.insert(dirs, d .. f .. "/")
			end
		end
	end
end

local function loadResourcesFromDirectory(directory)
	forAllFilesIn(directory .. "/Sprites/", function(d, f)
		if (f:sub(-4) == ".png") then
			sprites[f:sub(1, -5)] = lg.newImage(d .. f)
		end
	end)

	forAllFilesIn(directory .. "/Fonts/", function(d, f) 
		if (f:sub(-4) == ".ttf" or f:sub(-4) == ".otf") then
			local id = f:sub(1, -5)
			local size_file = d .. id .. ".size"
			local size = love.filesystem.getInfo(size_file) == nil and 12 or tonumber(love.filesystem.read(size_file), 10)
			fonts[id] = lg.newFont(d .. f, size)
			fonts[id]:setFilter("nearest", "nearest")
		end
	end)

	forAllFilesIn(directory .. "/Sounds/", function(d, f)
		if (table.containsValue(soundext, f:sub(-4))) then
			sounds[f:sub(1, -5)] = love.audio.newSource(d .. f, "static")
		end
	end)

	forAllFilesIn(directory .. "/Music/", function(d, f)
		if (table.containsValue(soundext, f:sub(-4))) then
			sounds[f:sub(1, -5)] = love.audio.newSource(d .. f, "stream")
		end
	end)

	forAllFilesIn(directory .. "/Voices/", function(d, f)
		if (table.containsValue(soundext, f:sub(-4))) then
			sounds["voice_" .. f:sub(1, -5)] = love.audio.newSource(d .. f, "static")
		end
	end)
end

local function loadAllMods()
	for i,f in pairs(love.filesystem.getDirectoryItems("Mods")) do
		if love.filesystem.getInfo("Mods/" .. f, "directory") then
			table.insert(mods, f)
			if love.filesystem.getInfo("Mods/" .. f .. "/Assets/preview.png", "file") then
				previews[i] = lg.newImage("Mods/" .. f .. "/Assets/preview.png")
			end
		end
	end
	Discord.SetTitle("Selecting a mod")
	Discord.ClearSubtitle(true)
	Discord.ClearTime()
	menu = "mods"
end

local function unloadAllMods()
	table.clear(previews)
	table.clear(mods)
	menu = "main"
end

local function loadCurrentMod()
	--For now, only one encounter per mod.
	Sprites = require("Engine/Handlers/sprites")
	Texts = require("Engine/Handlers/texts")
	Audio = require("Engine/Objects/audio")
	UI = require("Engine/Handlers/ui")
	Engine = require("Engine/engine")
	Fight = require("Engine/Handlers/fight")
	Act = require("Engine/Handlers/act")
	Inventory = require("Engine/Handlers/item")	
	Mercy = require("Engine/Handlers/mercy")
	Arena = require("Engine/Objects/arena")
	Player = require("Engine/Objects/player")
	
	modName = mods[mod]
	unloadAllMods()
	local dir = "Mods/" .. modName
	Encounter = require(dir .. "/Code/encounter")
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = require(dir .. "/Code/Monsters/" .. v)
		local e = Encounter.enemies[k]
		e.scriptName = v
		e.monstersprite = CreateSprite(e.sprite, Encounter.enemypositions[k][1], Encounter.enemypositions[k][2])
	end
	loadResourcesFromDirectory(dir .. "/Assets")
	Misc.setModDirectory(dir)
	Discord.SetTitle("Playing Mod: " .. modName)
	Discord.SetSubtitle("encounter")
	Discord.ClearTime()
	Engine.loadEngine()
	menu = "none"
end

function unloadCurrentMod()
	Audio.StopAll()
	table.clear(sprites)
	table.clear(fonts)
	table.clear(sounds)
	loadResourcesFromDirectory("Default")
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = v.scriptName
	end
	for k,v in pairs(package.loaded) do
		if k:sub(1, 4) == "Mods" or (k:sub(1, 6) == "Engine" and not table.containsValue(noreload, k:sub(16))) then
			package.loaded[k] = nil
		end
	end
	loadAllMods()
	modName = ""
end

function love.draw()
	Misc.draw()
	if menu == "main" then
		lg.draw(sprites["logo"], 320, 20, 0, 1, 1, sprites["logo"]:getWidth() / 2)
		lg.setColor(1, 1, 0)
		lg.printf("LOVE edition\n(Not level of violence)", fonts["uidialog"], 0, 110, lg.getWidth(), "center")
		lg.setColor(1, 1, 1)
		lg.printf({{1, 1, 1}, "Press", {1, 0, 0}, " ENTER", {1, 1, 1}, "\nfor mods"}, fonts["uidialog"], 0, 280, lg.getWidth(), "center")
	elseif (menu == "mods") then
		lg.translate(-640*(mod-1), 0)
		for i=1,#mods do
			local x = 640*(i-1)
			if previews[i] then
				lg.draw(previews[i], x, 0)
			end
			lg.setColor(0, 0, 0, 0.7)
			lg.draw(sprites["px"], x, 0, 0, lg.getWidth(), lg.getHeight())
			lg.setColor(1, 1, 1, 1)
			lg.printf(mods[i], fonts["uidialog"], x, 40, lg.getWidth(), "center")
		end
	elseif (menu == "none") then
		Engine.drawEngine()
	end
end

function love.load()
	sprites = {}
	fonts = {}
	sounds = {}
	loadResourcesFromDirectory("Default")
	print(love.system.getPowerInfo())
	love.window.setMode(640, 480)
	love.window.setTitle("LVup Your Frisk!")
end

function love.keyreleased(key, scancode)
	Input.keyreleased(key, scancode)
end

function love.update(dt)
	Discord.update(dt)
	Input.update(dt)
	Time.update(dt)
	Misc.update(dt)
	if menu == "main" and Input.IsDown("return") then
		loadAllMods()
	elseif (menu == "mods") then
		if Input.IsDown(Input.Confirm) then
			loadCurrentMod()
		elseif Input.IsDown("escape") then
			Discord.SetTitle("Title Screen")
			Discord.ClearTime()
			unloadAllMods()
		elseif Input.IsDown("right") then
			mod = mod + 1
		elseif Input.IsDown("left") then
			mod = mod - 1
		end
		mod = math.clamp(mod, 1, #mods, true)
	elseif (menu == "none") then
		Engine.updateEngine(dt)
		if (Input.IsDown("escape") and not Encounter.unescape) then
			unloadCurrentMod()
		end
	end
end

Discord = require("Engine/Objects/discord")
Input = require("Engine/Objects/input")
Time = require("Engine/Objects/time")
Misc = require("Engine/Objects/misc")