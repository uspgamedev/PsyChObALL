module('FileManager', base.globalize)

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
	if cheats.wasdev then return end
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
	soundmanager.volume = tonumber(config.volume) or 100
	soundmanager.muted  = config.muted == 'true'
	config.version = config.version or version

	if version ~= config.version then
		--handle something maybe
	end
	
	if ratio ~= 1 then love.graphics.setMode(math.floor(width*ratio), math.floor(height*ratio), false, false, 0) end
end

function writeConfig()
	writeCleanTable({
		screenratio = ratio,
		volume =	 soundmanager.volume,
		muted =	 soundmanager.muted,
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

local function getInfo( thing )
	if type(thing) == 'string' then
		return 's' .. thing:len()
	else
		return type(thing):sub(1, 1)
	end
end

function writeTableToString(t)
	local towrite = ''

	for key, value in pairs(t) do
		local extra1, extra2
		if type(key) == 'table' then
			extra1 = writeTableToString(key)
		elseif type(key) == 'function' then
			extra1 = string.dump(key) ..'\n'
		end

		if type(value) == 'table' then
			extra2 = writeTableToString(value)
		elseif type(value) == 'function' then
			extra2 = string.dump(value) .. '\n'
		end

		towrite = towrite .. getInfo(key) .. (extra1 and extra1:len() or '')
			..	'\n' .. getInfo(value) .. (extra2 and extra2:len() or '') .. '\n'

		towrite = towrite .. (extra1 or (tostring(key) .. '\n')) .. (extra2 or (tostring(value) .. '\n'))
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

local function getThing( info, nextLineFunc, str, curPos )
	if info == 'n' then -- it's a number
		local n = nextLineFunc()
		return tonumber(n), curPos + n:len() + 1
	elseif info == 'b' then -- it's a boolean
		local b = nextLineFunc()
		return b == 'true', curPos + b:len() + 1
	elseif info:sub(1, 1) == 's' then -- it's a string
		local charCount = tonumber(info:sub(2))
		return str:sub(curPos + 1, curPos + charCount), curPos + 1 + charCount
	elseif info:sub(1, 1) == 't' then -- it's a table
		local charCount = tonumber(info:sub(2))
		return readTableFromString(str:sub(curPos + 1, curPos + charCount)), curPos + charCount
	elseif info:sub(1, 1) == 'f' then
		local charCount = tonumber(info:sub(2))
		return loadstring(str:sub(curPos + 1, curPos + charCount)), curPos + charCount
	end
end

function readTableFromString( str )
	local pos, pos2 = 0, 0
	local t = {}
	local key, value, keyInfo, valueInfo
	local nextLine = function()
			pos, pos2 = str:find('[^\n]*\n', pos2 + 1)
			if pos2 then return str:sub(pos, pos2 - 1) end
		end
	while true do
		keyInfo = nextLine()
		if not keyInfo then break end

		valueInfo = nextLine()
		local prevp2 = pos2
		key, pos2 = getThing(keyInfo, nextLine, str, pos2)
		value, pos2 = getThing(valueInfo, nextLine, str, pos2)

		t[key] = value
	end
	return t
end