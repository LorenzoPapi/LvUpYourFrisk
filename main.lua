--might remove if I feel like it
lg = love.graphics
local menu = "main"
local mod = 1
local mods = {}
local previews = {}
local modName = ""
local soundext = {".wav", ".mp3", ".ogg"}
local noreload = {"input", "time", "misc", "discord"}
local forbidden = {"os", "io", "debug"}

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
		if (table.contains(soundext, f:sub(-4))) then
			sounds[f:sub(1, -5)] = love.audio.newSource(d .. f, "static")
		end
	end)

	forAllFilesIn(directory .. "/Music/", function(d, f)
		if (table.contains(soundext, f:sub(-4))) then
			sounds[f:sub(1, -5)] = love.audio.newSource(d .. f, "stream")
		end
	end)

	forAllFilesIn(directory .. "/Voices/", function(d, f)
		if (table.contains(soundext, f:sub(-4))) then
			sounds["voice_" .. f:sub(1, -5)] = love.audio.newSource(d .. f, "static")
		end
	end)
end

local function loadAllMods()
	for i,f in pairs(love.filesystem.getDirectoryItems("Mods")) do
		if love.filesystem.getInfo("Mods/" .. f, "directory") then
			table.insert(mods, f)
			if Misc.FileExists("Mods/" .. f .. "/Assets/preview.png") then
				previews[i] = lg.newImage("Mods/" .. f .. "/Assets/preview.png")
			end
		end
	end
	Discord.SetTitle("Selecting a mod")
	Discord.SetSubtitle("")
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
	Engine = require("Engine/engine")
	Arena = require("Engine/Objects/arena")
	Player = require("Engine/Objects/player")
	Audio = require("Engine/Objects/audio")
	Texts = require("Engine/Handlers/texts")
	Sprites = require("Engine/Handlers/sprites")
	Inventory = require("Engine/Handlers/item")
	Mercy = require("Engine/Handlers/mercy")
	Act = require("Engine/Handlers/act")
	Fight = require("Engine/Handlers/fight")
	UI = require("Engine/Handlers/ui")
	modName = mods[mod]
	unloadAllMods()
	local dir = "Mods/" .. modName
	Encounter = require(dir .. "/Code/encounter")
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = require(dir .. "/Code/Monsters/" .. v)
		Encounter.enemies[k].scriptName = v
	end
	loadResourcesFromDirectory("Default")
	loadResourcesFromDirectory(dir .. "/Assets")
	Misc.setModDirectory(dir)
	Engine.loadEngine()
	Discord.SetTitle("Playing Mod: " .. modName)
	Discord.SetSubtitle("encounter")
	Discord.ClearTime()
	menu = "none"
end

function unloadCurrentMod()
	Audio.StopAll()
	table.clear(sprites)
	table.clear(fonts)
	table.clear(sounds)
	loadAllMods()
	for k,v in pairs(package.loaded) do
		if k:sub(1, 6) == "Engine" and not table.contains(noreload, k:sub(16)) then
			package.loaded[k] = nil
		end
	end
	package.loaded["Mods/" .. modName .. "/Code/encounter"] = nil
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = v.scriptName
		package.loaded["Mods/"  .. modName .. "/Code/Monsters/" .. v.scriptName] = nil
	end
	loadResourcesFromDirectory("Default/")
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
		for i=1,#previews do
			local x = 640*(i-1)
			if not (previews[i] == nil) then
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
	print(love.system.getPowerInfo())
	love.window.setMode(640, 480)
	love.window.setTitle("LVup Your Frisk!")
	sprites = {}
	fonts = {}
	sounds = {}
	loadResourcesFromDirectory("Default/")
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

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function table.indexof(t, e)
	for _,v in pairs(t) do
		if (v == e) then
			return i
		end
	end
	return 0
end

function table.contains(t, e)
	for _,v in pairs(t) do
		if (v == e) then
			return true
		end
	end
	return false
end

function table.clear(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

function math.clamp(v, min, max, recur)
	if not (recur) then
		return math.max(min, math.min(v, max))
	end
	return (v > max) and min or (v < min and max or v)
end

function math.lerp(a, b, t)
	return (1-t)*a + t*b
end

local _require = require
function require(name)
	if not table.contains(forbidden, name) then
		return _require(name)
	else
		error("\nTrying to require a forbidden package?\nMistake or made on purpose?\nCaught in 4k.")
	end
end

function getfenv(f)
	error("\nTrying to get environment for something?\nMistake or made on purpose?\nCaught in 4k.")
end

function setfenv(f, t)
	error("\nTrying to set environment for something?\nMistake or made on purpose?\nCaught in 4k.")
end

Input = require("Engine/Objects/input")
Time = require("Engine/Objects/time")
Discord = require("Engine/Objects/discord")
Misc = require("Engine/Objects/misc")