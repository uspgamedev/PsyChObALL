snake = Body:new {
	size = 17,
	segmentsN = 5,
	shader = Base.circleShader,
	vulnerable = true,
	__type = 'snake'
}

Body.makeClass(snake)

function snake:draw()
	if self.first <= self.last then
		local s = self.segments[self.first]
		graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
	end
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, ColorManager.noLSDEffect))
	for i = self.first + 1, self.last, 1 do
		local s = self.segments[i]
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
	end
end

local auxVec = Vector:new{}

function snake:update( dt )
	local s = self.segments[self.first]

	while (s.position.x + self.size < 0 and s.speed.x <= 0) or (s.position.x > width + self.size and s.speed.x >= 0) or
		(s.position.y + self.size < 0 and s.speed.y <= 0) or (s.position.y > height + self.size and s.speed.y >= 0) do
		self.first = self.first + 1
		s.size = self.size
		Effect.createEffects(s, 20)

		if self.first > self.last then
			self:kill()
			break
		else
			s = self.segments[self.first]
			self.position = s.position
		end
	end

	for i = self.first, self.last, 1 do
		s = self.segments[i]
		s.position:add(auxVec:set(s.speed):mult(dt))
		
		Shot.bodies:forEachAlive(function(shot)
			if self.alive and Base.collides(s.position, self.size, shot.position, shot.size) then
				self:manageShotCollision(i, shot)
			end
		end)

		if psycho.canBeHit and not DeathManager.gameLost and Base.collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.causeOfDeath = "shot"
			DeathManager.manageDeath()
		end

		if s.target then
			local curdist = s.position:distsqr(self.path[s.target])
			if curdist < 1 or curdist > s.prevdist then
				s.position:set(self.path[s.target])
				s.target = s.target + 1
				local prev = self.segments[i - 1]
				if prev and prev.target == s.target then s.position:set(prev.position):sub(prev.speed:normalized():mult(self.size*2)) end
				if s.target > #self.path then
					s.prevdist = nil
					s.target = nil
				else 
					s.prevdist = s.position:distsqr(self.path[s.target])
					s.speed:set(self.path[s.target]):sub(s.position):normalize():mult(self.speedvalue)
				end
			else 
				s.prevdist = curdist
			end
		end
	end
end

function snake:manageShotCollision( segmentN, shot )
	local s = self.segments[segmentN]
	
	shot.explosionEffect = not self.vulnerable or segmentN ~= self.first
	shot:kill()
	
	if segmentN == self.first and self.vulnerable then
		RecordsManager.addScore(20)
		s.size = self.size
		Effect.createEffects(s, 20)
		self.segments[self.first] = nil
		self.first = self.first + 1
		if self.first > self.last then
			self:kill()
		else 
			self.position = self.segments[self.first].position
			if self.vulnerable then
				self.leadchange:setAndGo(0, 130, 130 / self.invulnerableCooldown)
				self.vulnerable = false
			end
		end
	end
end

function snake:revive( n, spd, invulnerableCooldown, p1, p2, ... )
	Body.revive(self)

	n = n or snake.segmentsN

	self.invulnerableCooldown = invulnerableCooldown or 1.5
	self.segmentsN = n
	self.segments = {}
	self.path = {p2, ...}
	self.position:set(p1)
	self.speedvalue = spd or v
	self.leadchange = VarTimer:new{var = 130, alsoCall = function() self.vulnerable = true end}
	self.coloreffect = ColorManager.getColorEffect({var = 122}, {var = 122}, {var = 122}, self.leadchange)

	self.speed:set(p2):sub(self.position):normalize():mult(spd or v * .8)
	self.first, self.last = 1, n

	return self
end

function snake:start()
	Body.start(self)

	local diff = self.speed:normalized():mult(self.size * 2)
	
	self.segments[1] = { speed = self.speed, position = self.position, prevdist = self.position:distsqr(self.path[1]), target = 1 }

	for i = 2, self.segmentsN, 1 do
		local s = {}
		s.speed = self.speed:clone()
		s.position = self.position - ((i - 1) * diff)
		s.prevdist = s.position:distsqr(self.path[1])
		s.target = 1
		self.segments[i] = s
	end

	if not self.vulnerable then
		self.coloreffect = ColorManager.noLSDEffect
	end
end