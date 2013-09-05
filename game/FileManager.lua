module('FileManager', Base.globalize)

function init()
	-- removing old stuff
	--[[if filesystem.exists 'stats' then
		filesystem.remove 'stats'
	end]]
end

function readStats()
	-- CHANGE THIS
	local stats = readTable "stats"

	besttime  = stats.besttime  or 0
	bestmult  = stats.bestmult  or 0
	bestscore = stats.bestscore or 0
	lastLevel = stats.lastLevel or 'Level 1-1'
end

function writeStats()
	-- CHANGE THIS
	if Cheats.wasdev then return end
	besttime  = math.max(besttime, gametime)
	bestmult  = math.max(bestmult, multiplier)
	bestscore = math.max(bestscore, score)
	writeTable({
		besttime  = besttime,
		bestmult  = bestmult,
		bestscore = bestscore,
		lastLevel = lastLevel
	}, "stats")
end

function resetStats()
	-- CHANGE THIS
	besttime, bestmult, bestscore  = 0, 0, 0
	writeTable({
		besttime  = 0,
		bestmult  = 0,
		bestscore = 0
	}, "stats")
end

function readConfig()
	local config = readCleanTable "config"

	global.ratio = tonumber(config.screenratio) or 1
	SoundManager.volume = tonumber(config.volume) or 100
	SoundManager.muted  = config.muted == 'true'
	config.version = config.version or version

	if version ~= config.version then
		--handle something maybe
	end
	
	if ratio ~= 1 then love.graphics.setMode(math.floor(width*ratio), math.floor(height*ratio), false, false, 0) end
end

function writeConfig()
	writeCleanTable({
		screenratio = ratio,
		volume =	 SoundManager.volume,
		muted =	 SoundManager.muted,
		version = version
	}, 'config')
end

function openFile( name, method )
	local file = filesystem.newFile(name)
	if not pcall(file.open, file, method) then
		print "some error ocurred"
		return nil
	end
	return file
end

-- considers everything to be one-line strings, output is better
function writeCleanTable( t, filename )
	local file = openFile(filename, 'w')
	if not file then return end
	local first = true

	for k, v in pairs(t) do
		if not first then file:write '\r\n' end
		first = false
		file:write(tostring(k))
		file:write ' = '
		file:write(tostring(v))
		file:write ';'
	end

	file:close()
end

function readCleanTable( filename )
	local t = {}
	local file = openFile(filename, 'r')
	if not file then return t end

	for key, value in file:read():gmatch('(%w+) = ([^;]+);\r?\n?') do
		t[key] = value
	end

	file:close()

	return t
end

-- writes a table to disk, supports writing numbers, strings, booleans, tables and functions
-- Obs. Assumes no tables contains itself (or any other kind of cyclic referencing)
function writeTable( t, filename )
	local file = openFile(filename, 'w')
	if not file then return end

	file:write(writeTableToString(t))

	file:close()
end

local function writeObject( obj )
	local t = type(obj)
	if t == 'number' then
		return 'n' .. obj .. ' '
	elseif t == 'boolean' then
		return 'b' .. (obj and '1 ' or '0 ')
	elseif t == 'function' then
		local str = string.dump(obj)
		return 'f' .. str:len() .. ' ' .. str
	elseif t == 'string' then
		return 's' .. obj:len() .. ' ' .. obj
	elseif t == 'table' then
		local str = writeTableToString(obj)
		return 't' .. str:len() .. ' ' .. str
	end
end

function writeTableToString(t)
	local towrite = ''

	for key, value in pairs(t) do
		towrite = towrite .. writeObject(key) .. writeObject(value)
	end

	return towrite
end

-- Reads a table from disk, supports reading numbers, strings, booleans, tables and functions
function readTable( filename )
	if not filesystem.exists(filename) then return {} end
	local file = filesystem.newFile(filename)
	if not pcall(file.open, file, 'r') then
		print "some error hapenned"
		return {}
	end

	return readTableFromString(file:read())
end

local readTableFromStringUnsafe

local function readObject( str, curPos )
	local newPos
	if not curPos then error()return nil, nil end
	local info = str:sub(curPos + 1, curPos + 1)
	if info == 'b' then -- it's a boolean
		return str:sub(curPos + 2, curPos + 2) == '1', curPos + 3
	end
	newPos = str:find(' ', curPos + 2)
	if not newPos then return nil, nil end
	local size = tonumber(str:sub(curPos + 2, newPos - 1))
	if info == 'n' then -- it's a number
		return size, newPos
	elseif info == 's' then -- it's a string
		return str:sub(newPos + 1, newPos + size), newPos + size
	elseif info == 't' then -- it's a table
		return readTableFromStringUnsafe(str:sub(newPos + 1, newPos + size)), newPos + size
	elseif info == 'f' then
		return loadstring(str:sub(newPos + 1, newPos + size)), newPos + size
	end
end

function readTableFromString( str )
	local ok, t = pcall(readTableFromStringUnsafe, str)
	if not ok then io.write("The table wasn't correct. (error: ", t, ')\n') return {} end
	return t
end

function readTableFromStringUnsafe( str )
	local pos = 0
	local t = {}
	local key, value
	while true do
		key, pos = readObject(str, pos)
		if key == nil then break end
		value, pos = readObject(str, pos)

		t[key] = value
	end
	return t
end