require 'lux.object'

function password( pass )
	if type(pass)=='string' then
		local str = pass
		pass = {}
		for char in str:gmatch '.' do table.insert(pass,char) end
	end
	local progress = 0
	return function ( key )
		if key == pass[progress + 1] then
			progress = progress + 1
			if progress == #pass then
				progress = 0
				return true
			end
		else
			progress = 0
			return false
		end
	end
end

function passwordtoggle( pass )
	local toggle = false
	local check = password(pass)
	return function ( key )
		if check(key) then toggle = not toggle end
		return toggle
	end
end

imagecheat = lux.object.new {
	pass = 'none',
	image = nil,
	painted = true,
	enabled = false,
	cheats = {}
}

function imagecheat:__init()
	table.insert(self.cheats, self)
	self.passcheck = password(self.pass)
	self.painted = self.painted == nil and true or self.painted
end

function imagecheat.processCheats( key )
	for _, cheat in ipairs(imagecheat.cheats) do
		if cheat.passcheck(key) then
			if imagecheat.image == cheat.image then
				imagecheat.enabled = false
				imagecheat.image = nil
			else
				imagecheat.enabled = true
				imagecheat.painted = cheat.painted
				imagecheat.image = cheat.image
				imagecheat.pass = cheat.pass
			end
		end
	end
end