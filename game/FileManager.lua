local filesystem, safeCall, print, toNumber = filesystem, pcall, print, tonumber
local floor, max, min, type, pairs, tostring = math.floor, math.max, math.min, type, pairs, tostring
local Levels = Levels
local global = _G
local FileManager = {}
setfenv(1, FileManager)

local defaultRecords = {
	survival = {
		score = 0,
		time = 0,
		multiplier = 0
	},
	story = {
		lastLevel = 'Level 1-1'
	}
}

function init()
	if filesystem.exists 'stats' then
		filesystem.remove 'stats'
	end

	for i = 1, global.Levels.worldsNumber do
		for j = 1, 4 do
			if i ~= 1 or j ~= 4 then
				defaultRecords.story['Level ' .. i .. '-' .. j] = {
					score = 0
				}
			end
		end
	end
end

function readStats()
	local stats = readTable "psycho.dat"

	global.records = stats.records or defaultRecords
	-- use other stats here
end

function writeStats()
	if global.Cheats.usedDevMode then return end
	local s = global.records.survival
	if global.state == global.survival then
		s.time  = max(s.time, global.gametime)
		s.multiplier  = max(s.multiplier, global.multiplier)
		s.score = max(s.score, global.score)
	end
	writeTable({
		records = global.records
	}, "psycho.dat")
end

function resetStats()
	global.records = defaultRecords
	-- default other stuff
	writeTable({
		records = global.records
	}, "psycho.dat")
end

function readConfig()
	local config = readCleanTable "config"

	global.ratio = toNumber(config.screenratio) or 1
	global.SoundManager.volume = toNumber(config.volume) or 100
	global.SoundManager.muted  = config.muted == 'true'
	config.version = config.version or global.version

	if global.version ~= config.version then
		--handle something maybe
	end
	
	if global.ratio ~= 1 then global.love.graphics.setMode(floor(global.width*global.ratio), floor(global.height*global.ratio), false, false, 0) end
end

function writeConfig()
	writeCleanTable({
		screenratio = global.ratio,
		volume =	 global.SoundManager.volume,
		muted =	 global.SoundManager.muted,
		version = global.version
	}, 'config')
end

function openFile( name, method )
	local file = filesystem.newFile(name)
	if not safeCall(file.open, file, method) then
		print "some error ocurred"
		return nil
	end
	return file
end

-- considers everything to be one-line strings, output is better looking
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
		local str = global.string.dump(obj)
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
	if not safeCall(file.open, file, 'r') then
		print "some error hapenned"
		return {}
	end

	return readTableFromString(file:read())
end

local readTableFromStringUnsafe

local function readObject( str, curPos )
	local newPos
	if not curPos then global.error() end
	local info = str:sub(curPos + 1, curPos + 1)
	if info == 'b' then -- it's a boolean
		return str:sub(curPos + 2, curPos + 2) == '1', curPos + 3
	end
	newPos = str:find(' ', curPos + 2)
	if not newPos then return nil, nil end
	local size = toNumber(str:sub(curPos + 2, newPos - 1))
	if info == 'n' then -- it's a number
		return size, newPos
	elseif info == 's' then -- it's a string
		return str:sub(newPos + 1, newPos + size), newPos + size
	elseif info == 't' then -- it's a table
		return readTableFromStringUnsafe(str:sub(newPos + 1, newPos + size)), newPos + size
	elseif info == 'f' then
		return global.loadstring(str:sub(newPos + 1, newPos + size)), newPos + size
	end
end

function readTableFromString( str )
	local ok, t = safeCall(readTableFromStringUnsafe, str)
	if not ok then global.io.write("The table wasn't correct. (error: ", t, ')\n') return {} end
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

return FileManager