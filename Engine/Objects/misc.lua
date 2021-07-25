--[[
	Credit to ally for the layout of the library (inspired by her gb library)
	I'm not super gud in lua so I get inspiration from great minds
]]

return (function()
	local self = {}

	self.MachineName = ""
	self.OsType = love.system.getOS()
	self.cameraX = 0
	self.cameraY = 0
	self.WindowX, self.WindowY = love.window.getPosition()
	self.WindowName = "LVup Your Frisk"

	local modFolder = ""
	local frame = 0
	local shakeThread = love.thread.newThread([[
		local total, int, decrease = ...

		local pos = love.thread.getChannel("pos")
		local f = love.thread.getChannel("frame")

		int = int or 3
		local frame = f:pop()
		local baseInt = int

		while true do
			if frame then
				if frame >= total then
					break
				end
				if decrease then
					int = baseInt * (1 - (frame / total))
				end
				pos:push({math.cos(frame) * int * math.random(), math.sin(frame) * int * math.random()})
			end
			if (love.thread.getChannel("kill"):pop()) then
				break
			end
			frame = f:pop()
		end
	]])

	function self.Load()
		if (self.OsType == "Windows") then
			self.MachineName = os.getenv("USERNAME")
		else
			self.MachineName = os.getenv("USER")
		end
		os = nil
		io = nil
	end

	function self.DestroyWindow()
		love.event.quit()
	end

	function self.MoveCamera(x, y)
		self.MoveCameraTo(self.cameraX + x, self.cameraY + y)
	end

	function self.MoveCameraTo(x, y)
		self.cameraX = x
		self.cameraY = y
	end

	function self.ResetCamera()
		self.MoveCameraTo(0, 0)
	end

	function self.ShakeScreen(frames, int, decrease)
		shakeThread:start(frames, int, decrease)
	end

	function self.StopShake()
		if (shakeThread:isRunning()) then
			love.thread.getChannel("kill"):push("DIE")
			frame = 0
		end
	end

	function self.MoveWindow(x, y)
		self.MoveWindowTo(self.WindowX + x, self.WindowY + y)
	end

	function self.MoveWindowTo(x, y)
		self.WindowX = x
		self.WindowY = y
		love.window.setPosition(x, y)
	end

	local function cleanAndAssert(path)
		assert(not path:find("%.%."), "\nCannot go up a folder!\nYou can only access files inside your mod folder!!")
		return modFolder .. path
	end

	function self.FileExists(path)
		return not (love.filesystem.getInfo(cleanAndAssert(path), "file") == nil)
	end

	function self.DirExists(path)
		return not (love.filesystem.getInfo(cleanAndAssert(path), "directory") == nil)
	end

	function self.ListDir(path, folders)
		local files = {}
		path = cleanAndAssert(path)
		for _,f in pairs(love.filesystem.getDirectoryItems(path)) do
			if love.filesystem.getInfo(f, "directory") and folders then
				table.insert(files, f)
			elseif not folders then
				table.insert(files, f)
			end
		end
		return files
	end

	function self.CreateDir(path)
		return love.filesystem.createDirectory(cleanAndAssert(path))
	end

	function self.MoveDir(path)
		--todo: create new dir and "move" (aka writing) files and whatever else is there
	end

	local function recursivelyDelete(item)
        if love.filesystem.getInfo(item, "directory") then
           	for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
               	recursivelyDelete(item .. '/' .. child)
               	love.filesystem.remove(item .. '/' .. child)
           	end

        elseif love.filesystem.getInfo(item) then
           	love.filesystem.remove(item)
        end
        love			.filesystem.remove(item)
    end

	function self.RemoveDir(path)
		local path = cleanAndAssert(path)
		recursivelyDelete(path)
    	return not self.DirExists(path)
	end

	function self.OpenFile(path)
		local path = cleanAndAssert(path)
		local obj, err = love.filesystem.newFile(path)
		if (err) then error(err) end
		return self.NewFile(obj, path)
	end

	function self.NewFile(obj, path)
		local _file = {}
		_file.obj = obj
		_file.filePath = path
		_file.lineCount = 0

		function _file.Move(path)
			local oldpath = _file.filePath
			_file.Copy(path, true)
			love.filesystem.remove(oldpath)

		end

		function _file.Copy(path, overwrite)
			local new = Misc.OpenFile(path)
			if not (#new.ReadBytes() == 0) and not overwrite then
				error("Cannot copy the file because it's already present!")
			end
			new.WriteBytes(_file.ReadBytes())
			_file.obj = new.obj
			_file.filePath = new.filePath
			new.obj:close()
		end

		function _file.ReadLine(line)
			local line = _file.ReadLines()[line]
			return line and line or ""
		end

		function _file.ReadLines()
			local lines = {}
			_file.obj:open("r")
			for l in _file.obj:lines() do
				table.insert(lines, l)
			end
			_file.lineCount = #lines
			_file.obj:close()
			return lines
		end

		function _file.ReadBytes()
			_file.obj:open("r")
			local content = _file.obj:read() or ""
			local bytes = {}
			for i=1,#content do
				table.insert(bytes, content:byte(i, i))
			end
			_file.obj:close()
			return bytes
		end

		function _file.Write(data, append)
			local mode = append and "a" or "w"
			_file.obj:open(mode)
			success, err = 	_file.obj:write(data)
			assert(not err, err)
			_file.obj:close()
		end

		function _file.ReplaceLine(line, data)
			local lines = _file.ReadLines()
			lines[line] = data
			_file.Write(table.concat(lines, "\n"))

		end

		function _file.DeleteLine(line)
			local lines = _file.ReadLines()
			table.remove(lines, line)
			_file.Write(table.concat(lines, "\n"))
		end

		function _file.WriteBytes(bytes, append)
			local data = {}
			for i=1,#bytes do
				data[i] = string.char(i)
			end
			_file.Write(table.concat(data, ""), append)
		end

		function _file.Delete()
			_file.obj:close()
			love.filesystem.remove(_file.filePath)
		end

		return _file
	end

	function self.setModDirectory(dir)
		modFolder = "/" .. dir .. "/"
	end

	function self.draw()
		lg.translate(self.cameraX, self.cameraY)
	end

	function self.update(dt)
		love.window.setTitle(self.WindowName)
		if (shakeThread:isRunning()) then
			local pos = love.thread.getChannel("pos"):pop()
			if (pos) then
				self.MoveCameraTo(pos[1], pos[2])
			end
			frame = frame + 1
			love.thread.getChannel("frame"):push(frame)
		end
	end

	function love.threaderror(thread, errorstr)
		error(errorstr)
	end
	
	return self
end)()