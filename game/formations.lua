require 'lux.object'

module ('formations', package.seeall)

formation = lux.object.new {
	name = 'empty',
	shootatplayer = false,
	shootattarget = false,
	__type = 'formation'
	-- add more stuff in here maybe
}

function formation:applyOn( enemies )
	if self.shootatplayer then
		self.shootattarget = true
		self.target = psycho.position
	end
end

empty = formation:new{}

function empty:applyOn( enemies )
	formation.applyOn(self, enemies)
	if self.shootattarget then
		local speed = self.speed or v
		for i = 1, #enemies do
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		end
	end
end

vertical = formation:new {
	name = 'vertical',
	from = 'top', --or 'bottom'
	movetorwards = 'center', -- or 'right' or 'left'
	startsat = width/2,
	distance = 'distribute' -- or any number
}

function vertical:applyOn( enemies )
	formation.applyOn(self, enemies)
	local y = self.from == 'top' and 0 or height
	local n = #enemies

	local dist, transl = 0, 0
	if self.movetorwards == 'center' then
		dist = self.distance == 'distribute' and width/n or self.distance
		transl = dist/2 + (self.distance == 'distribute' and 0 or self.startsat/2)
	else
		dist = self.distance == 'distribute' and (self.movetorwards == 'right' and (width - self.startsat) or self.startsat)/n or self.distance
		dist = self.movetorwards == 'right' and dist or -dist
		transl = self.startsat
	end

	local speed = self.speed or v
	for i = 1, n do
		enemies[i].position:set(transl + (i-1) * dist, y)

		if self.shootattarget then
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
	formation.applyOn(self, enemies)
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

	local speed = self.speed or v
	for i = 1, n do
		enemies[i].position:set(x, transl + (i-1) * dist)
		if self.shootattarget then
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		else
			if self.setspeedto or self.speed then
				enemies[i].speed:set(self.setspeedto or speed)
			else
				local l = enemies[n].speed:length()
				enemies[i].speed:set(x == 0 and l or -l, 0)
			end
		end
	end
end

line = formation:new {
	name = 'line',
	startpoint = nil, --vector
	dx = 20, dy = 20,
	distribute = false,
	distribute_between = nil --vector
}

function line:applyOn( enemies )
	formation.applyOn(self, enemies)
	local n = #enemies

	local transl = vector:new{self.dx,self.dy}
	if self.distribute then
		transl:set(self.distribute_between):sub(self.startpoint):div(n, n)
	end

	local speed = self.speed or v
	for i = 1, n do
		enemies[i].position:set(self.startpoint):add((i-1)*transl)
		if self.shootattarget then
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		else
			if self.setspeedto then
				enemies[i].speed:set(self.setspeedto)
			end
		end
	end
end

V = formation:new {
	name = 'V',
	size = nil,
	growth = nil,
	vertical = false
}

function V:applyOn( enemies )
	formation.applyOn(self, enemies)
	local n = #enemies

	local half = math.ceil(n/2)
	local even = n % 2 == 0
	local transl = vector:new{self.size/n, 2*self.growth/n}
	if self.vertical then transl[1], transl[2] = transl[2], transl[1] end
	local speed = self.speed or v
	local prevp = self.startpoint
	for i = 1, n do
		enemies[i].position:set(prevp):add(transl)
		prevp = enemies[i].position
		if even then 
			if i == half then
				if self.vertical then transl.x = 0
				else transl.y = 0 end
			elseif i == half + 1 then
				if self.vertical then transl.x = -2*self.growth/n
				else transl.y = -2*self.growth/n end
			end
		else
			if i == half then
				if self.vertical then transl.x = -transl.x
				else transl.y = -transl.y end
			end
		end

		if self.shootattarget then
			enemies[i].speed:set(self.target):sub(enemies[i].position):normalize():mult(speed, speed)
		else
			if self.setspeedto then
				enemies[i].speed:set(self.setspeedto)
			end
		end
	end
end