bossThree = body:new{
	size = 50,
	basespeed = 1.5*v,
	segmentsN = 17,
	__type = 'bossThree'
}

bossThree.behaviors = {}

function bossThree.behaviors.arriving( self )
	if self.y == 180 and self.x > width/2 then
		self.currentBehavior = donothing
		self.snakemode = true
		psychoball.min = function(a, b) return b end
		psychoball.max = psychoball.min
		self.currentBehavior = bossThree.behaviors.first
		local y = 300
		local dist = 60
		for i = 1, 7 do
			table.insert(self.path, {width - dist, y, onDeparture = bossThree.godown})
			dist = dist + 120
			if dist > width - self.size then dist = 60 end
			table.insert(self.path, {width - dist, y, onDeparture = bossThree.goright})
			y = y + 120
			if y > height - self.size then y = 60 end
		end
	end
end

function bossThree.behaviors.first( self )
	-- body
end

function bossThree.setspeed( speed )
	return function(s) s.speed:set(speed) end
end

bossThree.godown = bossThree.setspeed {0, bossThree.basespeed}
bossThree.goleft = bossThree.setspeed {-bossThree.basespeed, 0}
bossThree.goright = bossThree.setspeed {bossThree.basespeed, 0}
bossThree.goup = bossThree.setspeed {0, -bossThree.basespeed}

function bossThree:draw()
	if not psycho.extraposition:equals(0, 0) then
		psycho.position:add(psycho.extraposition)
		psycho.size = psycho.size + psycho.sizediff
		body.draw(psycho)
		psycho.position:sub(psycho.extraposition)
		psycho.size = psycho.size - psycho.sizediff
	end
	if self.first ~= self.last then
		local s = self.segments[self.first]
		graphics.setColor(color(colortimer.time + self.variance, nil, self.coloreffect))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.circle(self.mode, s.position[1] + s.extraposition[1], s.position[2] + s.extraposition[2], self.size)
	end
	for i = self.first + 1, self.last, 1 do
		local s = self.segments[i]
		graphics.setColor(color(colortimer.time + self.variance, nil, noLSDeffect))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.circle(self.mode, s.position[1] + s.extraposition[1], s.position[2] + s.extraposition[2], self.size)
	end
end

function bossThree:update( dt )
	self:currentBehavior()

	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		s.position:add(s.speed*dt)
		for _, v in pairs(shot.bodies) do
			if collides(s.position, self.size, v.position, v.size) then
				v.collides = true
				v.explosionEffect = true
			end
		end

		if psycho.canbehit and not gamelost and collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.diereason = "shot"
			lostgame()
		end

		if self.snakemode then
			if s.position[1] < self.size or s.position[1] > width - self.size then
				if s.position[1] < 0 or s.position[1] > width then
					s.position[1] = s.position[1] + (s.position[1] < width/2 and width or -width)
					s.extraposition:set(s.position[1] < width/2 and width or -width, nil)
				else
					s.extraposition:set(s.position[1] < width/2 and width or -width, nil)
				end
			else
				s.extraposition:set(0, nil)
			end
			if s.position[2] < self.size or s.position[2] > height - self.size then
				if s.position[2] < 0 or s.position[2] > height then
					s.position[2] = s.position[2] + (s.position[2] < height/2 and height or -height)
					s.extraposition:set(nil, s.position[2] < height/2 and height or -height)
				else
					s.extraposition:set(nil, s.position[2] < height/2 and height or -height)
				end
			else
				s.extraposition:set(nil, 0)
			end
		end
			
		if s.target <= #self.path then
			local p = self.path[s.target]
			local curdist = s.position:distsqr(p)
			if curdist < 1 or (curdist < 12 and curdist > s.prevdist) then
				s.position:set(p)
				if p.onArrival then p.onArrival(s) end
				s.target = s.target + 1
				if s.target > #self.path then 
				else 
					p = self.path[s.target]
					s.prevdist = s.position:distsqr(p)
					if p.onDeparture then p.onDeparture(s)
					else s.speed:set(p):sub(s.position):normalize():mult(bossThree.basespeed) end
				end
			else 
				s.prevdist = curdist
			end
		end
	end

	if self.snakemode then
		if psycho.x < psycho.size or psycho.x > width - psycho.size then
			if psycho.x < 0 or psycho.x > width then
				psycho.x = psycho.x + (psycho.x < width/2 and width or -width)
				psycho.extraposition:set(psycho.x < width/2 and width or -width, nil)
			else
				psycho.extraposition:set(psycho.x < width/2 and width or -width, nil)
			end
		else
			psycho.extraposition:set(0, nil)
		end
		if psycho.y < psycho.size or psycho.y > height - psycho.size then
			if psycho.y < 0 or psycho.y > height then
				psycho.y = psycho.y + (psycho.y < height/2 and height or -height)
				psycho.extraposition:set(nil, psycho.y < height/2 and height or -height)
			else
				psycho.extraposition:set(nil, psycho.y < height/2 and height or -height)
			end
		else
			psycho.extraposition:set(nil, 0)
		end
	end
end

function bossThree:__init()
	psycho.extraposition = vector:new{0,0}
	local n = self.segmentsN
	self.path = {{60, 60}, {60, 180}, {width - 60, 180}}
	self.position = vector:new{width + 60, 60}
	self.segments = {}
	self.speedvalue = spd
	self.leadchange = vartimer:new{var = 30}
	self.coloreffect = getColorEffect({var = 122}, {var = 122}, {var = 122}, self.leadchange)
	local speed = vector:new(clone(self.path[1])):sub(self.position):normalize()
	local diff = speed * (self.size*2)
	speed:mult(bossThree.basespeed)
	self.speed = speed:clone()
	self.first, self.last = 1, n
	self.segments[1] = { speed = speed, position = self.position, extraposition = vector:new{0,0}, prevdist = self.position:distsqr(self.path[1]), target = 1 }
	self.currentBehavior = bossThree.behaviors.arriving
	for i = 2, n, 1 do
		local s = {}
		s.speed = speed:clone()
		s.position = self.position - ((i - 1)*diff)
		s.prevdist = s.position:distsqr(self.path[1])
		s.target = 1
		s.extraposition = vector:new{0, 0}
		self.segments[i] = s
	end
end