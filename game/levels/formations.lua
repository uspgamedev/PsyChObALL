require 'lux.object'

module('levels.formations', package.seeall)

formation = lux.object.new {
	name = 'formation_name',
	shootatplayer = false,
	shootattarget = false
	-- add more stuff in here maybe
}

vertical = formation:new {
	name = 'vertical',
	from = 'top', --or 'bottom'
	movetorwards = 'center', -- or 'right' or 'left'
	startsat = width/2,
	distance = 'distribute' -- or any number
}

function vertical:applyOn( enemies )
	local y = self.from == 'top' and 0 or height
	local n = #enemies

	if self.shootatplayer then
		self.shootattarget = true
		self.target = psycho.position
	end

	local dist, transl = 0, 0
	if self.movetorwards == 'center' then
		dist = self.distance == 'distribute' and width/n or self.distance
		transl = dist/2 + (self.distance == 'distribute' and 0 or self.startsat/2)
	else
		dist = self.distance == 'distribute' and (self.movetorwards == 'right' and (width - self.startsat) or self.startsat)/n or self.distance
		dist = self.movetorwards == 'right' and dist or -dist
		transl = self.startsat
	end

	for i = 1, n do
		enemies[i].position:set(transl + (i-1) * dist, y)

		if self.shootattarget then
			local speed = self.speed or v
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		else
			if self.setspeedto or self.speed then
				enemies[i].speed:set(self.setspeedto or 0, self.speed)
			else
				local l = enemies[n].speed:length()
				enemies[i].speed:set(0, y == 0 and l or -l)
			end
		end
	end
end

horizontal = formation:new {
	name = 'horizontal',
	from = 'left', -- or 'right'
	movetorwards = 'center', -- or 'down' or 'up'
	startsat = height/2,
	distance = 'distribute' -- or any number
}

function horizontal:applyOn( enemies )
	local x = self.from == 'left' and 0 or width
	local n = #enemies

	if self.shootatplayer then
		self.shootattarget = true
		self.target = psycho.position
	end

	local dist, transl = 0, 0
	if self.movetorwards == 'center' then
		dist = self.distance == 'distribute' and height/n or self.distance
		transl = dist/2 + (self.distance == 'distribute' and 0 or self.startsat/2)
	else
		dist = self.distance == 'distribute' and (self.movetorwards == 'down' and (height - self.startsat) or self.startsat)/n or self.distance
		dist = self.movetorwards == 'down' and dist or -dist
		transl = self.startsat
	end

	for i = 1, n do
		enemies[i].position:set(x, transl + (i-1) * dist)
		if self.shootattarget then
			local speed = self.speed or v
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		else
			if self.setspeedto or self.speed then
				enemies[i].speed:set(self.setspeedto or self.speed)
			else
				local l = enemies[n].speed:length()
				enemies[i].speed:set(x == 0 and l or -l, 0)
			end
		end
	end
end