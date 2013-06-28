module('filemanager', base.globalize)

function readstats()
	local stats = filemanager.readtable "stats"

	besttime  = stats.besttime  or 0
	bestmult  = stats.bestmult  or 0
	bestscore = stats.bestscore or 0
end

function writestats()
	if cheats.wasdev then return end
	if besttime > totaltime and bestmult > multiplier and bestscore > score then return end
	besttime  = math.max(besttime, totaltime)
	bestmult  = math.max(bestmult, multiplier)
	bestscore = math.max(bestscore, score)
	filemanager.writetable({
		besttime  = besttime,
		bestmult  = bestmult,
		bestscore = bestscore
	}, "stats")
end

function resetstats()
	besttime, bestmult, bestscore  = 0, 0, 0
	filemanager.writetable({
		besttime  = 0,
		bestmult  = 0,
		bestscore = 0
	}, "stats")
end

--[[function readachievements()
	local achievements = filemanager.readtable "achievements"

	twentymult  = achievements.twentymult or false
end

function writeachievements()
	filemanager.writetable({
		twentymult  = twentymult
	}, "achievements")
end]]

function readconfig()
	local config = readtable "config"

	soundmanager.volume = config.volume or 100
	soundmanager.muted  = config.muted == true

	if version ~= config.version then
		--handle something maybe
	end

	local options = readCleanTable 'options'

	global.ratio = tonumber(options.screenratio) or 1
	if ratio ~= 1 then love.graphics.setMode(math.floor(width*ratio), math.floor(height*ratio), false) end
end

function writeconfig()
	writetable({
		volume =	 soundmanager.volume,
		muted =	 soundmanager.muted,
		version = version
		}, "config")
	writeCleanTable({screenratio = ratio}, 'options')
end

-- considers everything to be strings, output is better
function writeCleanTable( t, filename )
	local file = filesystem.newFile(filename)
	if not pcall(file.open, file, 'w') then
		print "some error ocurred"
		return
	end

	for k, v in pairs(t) do
		file:write(k)
		file:write(' = ')
		file:write(v)
		file:write(';\n')
	end

	file:close()
end

function readCleanTable( filename )
	if not filesystem.exists(filename) then return {} end
	local file = filesystem.newFile(filename)
	local t = {}
	if not pcall(file.open, file, 'r') then
		print "some error hapenned"
		return t
	end

	local lines = file:lines()
	local line
	repeat
		line = lines()
		if not line then break end
		k, value = line:gmatch('(%w+) = (.+);')()
		t[k] = value
	until false

	file:close()

	return t
end

-- writes a table to disk, supports writing numbers, strings and booleans for now
function writetable( t, filename )
	--local usedTables = {t} --used to avoid infinite looping --not used yet
	local file = filesystem.newFile(filename)
	if not pcall(file.open, file, 'w') then
		print "some error ocurred"
		return
	end

	file:write(filemanager.writestring(t))

	file:close()
end

function writestring(t)
	local towrite = ''
	for k, v in pairs(t) do
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
			towrite = towrite .. 's ' .. lines .. '\n' .. v
		end

		towrite = towrite .. '\n'
	end
	return towrite
end

-- read a table from disk, supports reading numbers, strings and booleans for now
function readtable( filename )
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