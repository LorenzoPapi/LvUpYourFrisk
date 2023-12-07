local forbidden = {"os", "io", "debug"}
local time = os.time
local getenv = os.getenv
local getinfo = debug.getinfo
os = nil
io = nil
debug = nil

os = {}
debug = {}
debug.getinfo = getinfo
os.time = time
os.getenv = getenv

local _require = require
function require(name)
	if not table.containsValue(forbidden, name) then
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

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function table.indexof(t, e)
	for i,v in pairs(t) do
		if (v == e) then
			return i
		end
	end
	return 0
end

function table.containsValue(t, e)
	for _,v in pairs(t) do
		if (v == e) then
			return true
		end
	end
	return false
end

function table.containsKey(t, e)
	for k in pairs(t) do
		if (k == e) then
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
	if recur then
		return (v > max) and min or (v < min and max or v)
	end
	return math.max(min, math.min(v, max))
end

function math.lerp(a, b, t)
	return (1-t)*a + t*b
end

function regularVertices(r, x, y, n)
	local theta = math.rad(360 / n)
	local a = {}
	for i=1,n*2,2 do
		local angle = theta * math.floor(i / 2)
		a[i] = x + r * math.cos(angle)
		a[i+1] = y + r * math.sin(angle)
	end
	return a
end

function createSpecialTable(t, onaccess)
	local proxy = t
	t = {}
	setmetatable(t, {
		__index = function(t, k)
			return proxy[k]
		end,
		__newindex = function(t, k, v)
			proxy[k] = v
			onaccess(proxy, k, v, t)
		end
	})
	return t
end