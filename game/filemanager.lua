module('filemanager', base.globalize)

function readstats()
	local stats = filemanager.readTable "stats"

	besttime  = stats.besttime  or 0
	bestmult  = stats.bestmult  or 0
	bestscore = stats.bestscore or 0
end

function writestats()
	if cheats.wasdev then return end
	if besttime >= gametime and bestmult >= multiplier and bestscore >= score then return end
	besttime  = math.max(besttime, gametime)
	bestmult  = math.max(bestmult, multiplier)
	bestscore = math.max(bestscore, score)
	filemanager.writeTable({
		besttime  = besttime,
		bestmult  = bestmult,
		bestscore = bestscore
	}, "stats")
end

function resetstats()
	besttime, bestmult, bestscore  = 0, 0, 0
	filemanager.writeTable({
		besttime  = 0,
		bestmult  = 0,
		bestscore = 0
	}, "stats")
end

--[[function readachievements()
	local achievements = filemanager.readTable "achievements"

	twentymult  = achievements.twentymult or false
end

function writeachievements()
	filemanager.writeTable({
		twentymult  = twentymult
	}, "achievements")
end]]

function readconfig()
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

function writeconfig()
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

-- considers everything to be strings, output is better
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

-- writes a table to disk, supports writing numbers, strings and booleans for now
function writeTable( t, filename )
	--local usedTables = {t} --used to avoid infinite looping --not used yet
	local file = openFile(filename, 'w')
	if not file then return end

	file:write(writestring(t))

	file:close()
end

function writestring(t)
	local towrite = ''
	local first = true
	for k, v in pairs(t) do
		if not first then towrite = towrite .. '\r\n' end
		first = false

		if type(k) == 'string' then
			towrite = towrite .. k .. ' =s'
		elseif type(k) == 'number' then
			towrite = towrite .. k .. ' =n'
		end

		if type(v) == 'number' then
			towrite = towrite .. 'n ' .. v
		elseif type(v) == 'boolean' then
			towrite = towrite .. 'b ' .. (v and 'true' or 'false')
		elseif type(v) == 'string' then
			local lines, pos = 0, 0
			repeat lines = lines + 1 pos = v:find('\n',pos + 1) until pos == nil
			towrite = towrite .. 's ' .. lines .. '\r\n' .. v
		end
	end
	return towrite
end

-- read a table from disk, supports reading numbers, strings and booleans for now
function readTable( filename )
	if not filesystem.exists(filename) then return {} end
	local file = filesystem.newFile(filename)
	local t = {}
	if not pcall(file.open, file, 'r') then
		print "some error hapenned"
		return t
	end

	local key, keyinfo, info, value
	local lines = file:lines()
	local line
	repeat
		line = lines()
		if line == nil then break end
		key, keyinfo, info, value = line:gmatch('(%w+) =(.)(.) (.+)')()
		if keyinfo == 'n' then key = tonumber(key) end

		if info == 'n' then --it's a number
			value = tonumber(value)
		elseif info == 'b' then --it's a boolean
			value = value == 'true'
		elseif info == 's' then --it's a string
			local s = lines()
			for i = 2,tonumber(value) do
				s = s .. '\n' .. lines()
			end
			value = s
		end
		if key~=nil then t[key] = value end
	until false

	file:close()
	return t
end