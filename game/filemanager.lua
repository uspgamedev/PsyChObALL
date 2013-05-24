module('filemanager', package.seeall)

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
		return {}
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