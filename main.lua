--might remove if I feel like it
lg = love.graphics
local menu = "main"
local mod = 1
local mods = {}
local previews = {}
local soundext = {".wav", ".mp3", ".ogg"}

local function loadResourcesFromDirectory(directory)
	local dir = directory .. "/Sprites/"
	local dirs = {}
	table.insert(dirs, dir)

	for _,d in pairs(dirs) do
		for _,f in pairs(love.filesystem.getDirectoryItems(d)) do
			if (f:sub(-4) == ".png") then
				sprites[f:sub(1, -5)] = lg.newImage(d .. f)
			elseif not (f:find("\\.")) then
				table.insert(dirs, d .. f .. "/")
			end
		end
	end

	dir = directory .. "/Fonts/"
	table.clear(dirs)
	table.insert(dirs, dir)

	for _,d in pairs(dirs) do
		for _,f in pairs(love.filesystem.getDirectoryItems(d)) do
			if (f:sub(-4) == ".ttf" or f:sub(-4) == ".otf") then
				local id = f:sub(1, -5)
				local size_file = d .. id .. ".size"
				local size = love.filesystem.getInfo(size_file) == nil and 12 or tonumber(love.filesystem.read(size_file), 10)
				fonts[id] = lg.newFont(d .. f, size)
				fonts[id]:setFilter("nearest", "nearest")
			elseif not (f:find("\\.")) then
				table.insert(dirs, d .. f .. "/")
			end
		end
	end

	dir = directory .. "/Sounds/"
	table.clear(dirs)
	table.insert(dirs, dir)

	for _,d in pairs(dirs) do
		for _,f in pairs(love.filesystem.getDirectoryItems(d)) do
			if (table.contains(soundext, f:sub(-4))) then
				local id = f:sub(1, -5)
				sounds[id] = love.audio.newSource(d .. f, "static")
			elseif not (f:find("\\.")) then
				table.insert(dirs, d .. f .. "/")
			end
		end
	end

	dir = directory .. "/Music/"
	table.clear(dirs)
	table.insert(dirs, dir)

	for _,d in pairs(dirs) do
		for _,f in pairs(love.filesystem.getDirectoryItems(d)) do
			if (table.contains(soundext, f:sub(-4))) then
				local id = f:sub(1, -5)
				sounds[id] = love.audio.newSource(d .. f, "stream")
			elseif not (f:find("\\.")) then
				table.insert(dirs, d .. f .. "/")
			end
		end
	end
end

local function loadAllMods()
	for i,f in pairs(love.filesystem.getDirectoryItems("Mods")) do
		if not (f:find("\\.")) then
			table.insert(mods, f)
			if not (love.filesystem.getInfo("Mods/" .. f .. "/Assets/preview.png") == nil) then
				previews[i] = lg.newImage("Mods/" .. f .. "/Assets/preview.png")
			end
		end
	end
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

	local dir = "Mods/" .. mods[mod]
	Encounter = require(dir .. "/Code/encounter")
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = require(dir .. "/Code/Monsters/" .. v)
		Encounter.enemies[k].scriptName = v
	end
	loadResourcesFromDirectory("Default")
	loadResourcesFromDirectory(dir .. "/Assets")
	unloadAllMods()
	Engine.loadEngine()
	menu = "none"
end

function unloadCurrentMod()
	table.clear(sprites)
	table.clear(fonts)
	table.clear(sounds)
	Audio.StopAll()
	loadAllMods()
	for k,v in pairs(package.loaded) do
		if (k:sub(1, 6) == "Engine") then
			package.loaded[k] = nil
		end
	end
	package.loaded["Mods/" .. mods[mod] .. "/Code/encounter"] = nil
	for k,v in ipairs(Encounter.enemies) do
		Encounter.enemies[k] = v.scriptName
		package.loaded["Mods/"  .. mods[mod] .. "/Code/Monsters/" .. v.scriptName] = nil
	end
	loadResourcesFromDirectory("Default/")
end

function love.draw()
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
	love.window.setMode(640, 480)
	sprites = {}
	fonts = {}
	sounds = {}
	loadResourcesFromDirectory("Default/")
end

function love.keypressed(key, scancode, isrepeat)
	if menu == "main" and Input.equals(key, "Confirm") then
		loadAllMods()
	elseif (menu == "mods") then
		if (Input.equals(key, "Confirm")) then
			loadCurrentMod()
		elseif key == "escape" then
			unloadAllMods()
		elseif key == "right" then
			mod = mod + 1
		elseif key == "left" then
			mod = mod - 1
		end
		mod = math.clamp(mod, 1, #mods, true)
	elseif (menu == "none") then
		if (key == "escape" and not Encounter.unescape) then
			unloadCurrentMod()
		end
		Engine.keypressed(key, scancode, isrepeat)
	end
end

function love.update(dt)
	if (menu == "none") then
		Engine.updateEngine(dt)
	end
end

function string:split(sep)
	local sep, fields = sep or ":", {}
   	local pattern = string.format("([^%s]+)", sep)
   	self:gsub(pattern, function(c) fields[#fields+1] = c end)
   	return fields
end

function table.indexof(t, e)
	for i=1,#t do
		if (t[i] == e) then
			return i
		end
	end
	return nil
end

function table.contains(t, e)
	for i=1,#t do
		if (t[i] == e) then
			return true
		end
	end
	return false
end

function table.clear(t)
	for i=1,#t do
		t[i] = nil
	end
end

function math.clamp(value, min, max, recur)
	if (value > max) then
		return recur and min or max
	elseif (value < min) then
		return recur and max or min
	else
		return value
	end
end

function math.lerp(a, b, t)
	return (1-t)*a + t*b
end

Input = {
	Confirm = 	{"z", "return"},
	Cancel 	= 	{"x", "lshift"},
	Up 		=	{"w", "up"},
	Left 	=	{"a", "left"},
	Right 	= 	{"s", "right"},
	Down 	=	{"d", "down"}
}

function Input.equals(code, typein)
	for i=1,#Input[typein] do
		if (code == Input[typein][i]) then
			return true
		end	
	end
end

function Input.isDown(typein)
	for i=1,#Input[typein] do
		if (love.keyboard.isDown(Input[typein][i])) then
			return true
		end	
	end
end