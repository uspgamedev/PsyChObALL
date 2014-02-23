module('Cheats', Base.globalize)

devmode = false
invisible = false
usedDevMode = false
konamicode = false
imagecheats = {}

function password( pass )
	if type(pass) == 'string' then
		local str = pass
		pass = {}
		for char in str:gmatch '.' do pass[#pass + 1] = char end
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
	tiltpass = passwordtoggle 'tilt'
	konamipass = password {'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'}
	
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
			if devmode then usedDevMode = true return end
		end

		invisible = invisiblepass(key)
		image.processCheats(key)

		if tiltmode then
			tiltmode = tiltpass(key)
			if not tiltmode then angle:setAndGo(nil, 0, 1) end
		else
			tiltmode = tiltpass(key)
			if tiltmode then angle:setAndGo(nil, math.pi/25, 1) end
		end

		if devmode then
			if not esc and key == 'k' then DeathManager.manageDeath() end
			if     key == '9' then RecordsManager.records.story.lastLevel = 'Level 5-4'
			elseif key == '8' then RecordsManager.addScore(100)
			elseif key == '7' then RecordsManager.addScore(-100)
			elseif key == '6' then v = v + 10
			elseif key == '5' then v = v - 10
			elseif key == '4' then timeFactor = timeFactor * 1.1
			elseif key == '3' then timeFactor = timeFactor * 0.9
			elseif key == '2' then psycho:addLife()
			elseif key == '1' then psycho:removeLife()
			elseif key == 'l' and not DeathManager.gameLost then DeathManager.getDeathText(1) DeathManager.manageDeath()
			elseif key == 'x' then psycho.ultraCounter = psycho.ultraCounter + 1
			elseif key == 'g' then godmode = not godmode
			elseif key == 'e' then 
				local effectCount = 0
				for _, __ in pairs(Effect.bodies) do effectCount = effectCount + 1 end
				print(effectCount)
			elseif key == 'o' then timeFactor = 1
			elseif key == 'j' then Shot.shotnum = Shot.shotnum == 1 and 10 or 1
			end
		end
		
	end

	if onMenu() then
		konamicode = konamipass(key)
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