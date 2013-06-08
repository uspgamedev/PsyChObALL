module('cheats', base.globalize)

devmode = false
invisible = false
wasdev = false
imagecheats = {}

function password( pass )
	if type(pass) == 'string' then
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

function init()
	devpass = passwordtoggle 'psycho'
	invisiblepass = passwordtoggle 'ghost'
	tiltpass = password 'tilt'

	image:new {
		pass = 'pizza',
		image = 	graphics.newImage("resources/pizza.png"),
		painted = false
	}
	image:new {
		pass = 'yan',
		image = graphics.newImage("resources/yan.png")
	}
	image:new {
		pass = 'rica',
		image = graphics.newImage("resources/rica.png")
	}
	image:new {
		pass = 'rika',
		image = graphics.newImage("resources/rika.png")
	}
end

function keypressed( key )
	if onGame() then
		
		if devmode then
			devmode = devpass(key)
		else
			devmode = devpass(key)
			if devmode then wasdev = true return end
		end

		invisible = invisiblepass(key)
		image.processCheats(key)

		if tiltpass(key) then angle:setAndGo(0, math.pi/25, 1) end

		if devmode then
			if not esc and key == 'k' then lostgame() end
			if 	 key == '0' then multiplier = multiplier + 2
			elseif key == '9' then multiplier = multiplier - 2
			elseif key == '8' then addscore(100)
			elseif key == '7' then addscore(-100)
			elseif key == '6' then v = v + 10
			elseif key == '5' then v = v - 10
			elseif key == '4' then timefactor = timefactor * 1.1
			elseif key == '3' then timefactor = timefactor * 0.9
			elseif key == 'l' and not gamelost then deathText(1) lostgame()
			elseif key == 'u' then love.update(10) --skips 10 seconds
			end
		end
	end
end

image = lux.object.new {
	pass = 'none',
	image = nil,
	painted = true,
	enabled = false
}

function image:__init()
	table.insert(imagecheats, self)
	self.passcheck = password(self.pass)
	self.painted = self.painted == nil and true or self.painted
end

function image.processCheats( key )
	for _, icheat in ipairs(imagecheats) do
		if icheat.passcheck(key) then
			if image.image == icheat.image then
				image.enabled = false
				image.image = nil
			else
				image.enabled = true
				image.painted = icheat.painted
				image.image = icheat.image
				image.pass = icheat.pass
			end
		end
	end
end