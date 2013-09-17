local lux = lux
local type, print, pairs = type, print, pairs
local global = _G
local Cheats = {}
setfenv(1, Cheats)

devmode = false
invisible = false
imaegmode = false
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
	allimagespass = passwordtoggle 'bighead'
	konamipass = password {'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'}
	
	image:new {
		pass = 'pizza',
		image = 	global.graphics.newImage("resources/pizza.png"),
		painted = false
	}
	image:new {
		pass = 'yan',
		image = global.graphics.newImage("resources/yan.png")
	}
	image:new {
		pass = 'rica',
		image = global.graphics.newImage("resources/rica.png")
	}
	image:new {
		pass = 'rika',
		image = global.graphics.newImage("resources/rika.png")
	}
end

function keypressed( key )
	if global.onGame() then
		
		if devmode then
			devmode = devpass(key)
		else
			devmode = devpass(key)
			if devmode then usedDevMode = true return end
		end

		invisible = invisiblepass(key)
		dkmode = allimagespass(key)
		global.CircleEffect.changesimage = dkmode
		image.processCheats(key)

		if tiltmode then
			tiltmode = tiltpass(key)
			if not tiltmode then global.angle:setAndGo(nil, 0, 1) end
		else
			tiltmode = tiltpass(key)
			if tiltmode then global.angle:setAndGo(nil, math.pi/25, 1) end
		end

		if devmode then
			if not global.isPaused and key == 'k' then global.DeathManager.manageDeath() end
			if 	 key == '0' then global.multiplier = global.multiplier + 2
			elseif key == '9' then global.multiplier = global.multiplier - 2
			elseif key == '8' then global.addscore(100)
			elseif key == '7' then global.addscore(-100)
			elseif key == '6' then global.v = global.v + 10
			elseif key == '5' then global.v = global.v - 10
			elseif key == '4' then global.timefactor = global.timefactor * 1.1
			elseif key == '3' then global.timefactor = global.timefactor * 0.9
			elseif key == '2' then global.psycho:addLife()
			elseif key == '1' then global.psycho:removeLife()
			elseif key == 'l' and not global.DeathManager.gameLost then global.DeathManager.getDeathText(1) global.DeathManager.manageDeath()
			elseif key == 'x' then global.ultracounter = global.ultracounter + 1
			elseif key == 'g' then global.godmode = not global.godmode
			elseif key == 'e' then 
				local effectCount = 0
				for _, __ in pairs(global.Effect.bodies) do effectCount = effectCount + 1 end
				print(effectCount)
			elseif key == 'r' then global.timefactor = 1
			elseif key == 'j' then global.Shot.shotnum = global.Shot.shotnum == 1 and 10 or 1
			end
		end
		
	end

	if global.onMenu() then
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
	imagecheats[#imagecheats + 1] = self
	self.passcheck = password(self.pass)
	self.painted = self.painted == nil and true or self.painted
end

function image.processCheats( key )
	local icheat
	for i = 1, #imagecheats do
		icheat = imagecheats[i]
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

return Cheats