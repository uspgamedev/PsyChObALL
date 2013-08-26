snake = Body:new {
	size = 17,
	segmentsN = 5,
	vulnerable = true,
	__type = 'snake'
}

Body.makeClass(snake)

function snake:draw()
	if self.first <= self.last then
		graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
		graphics.circle(self.mode, self.segments[self.first].position[1], self.segments[self.first].position[2], self.size)
	end
	for i = self.first + 1, self.last, 1 do
		graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, ColorManager.noLSDEffect))
		graphics.circle(self.mode, self.segments[i].position[1], self.segments[i].position[2], self.size)
	end
end

local auxVec = Vector:new{}

function snake:update( dt )
	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		s.position:add(auxVec:set(s.speed):mult(dt))
		for _, v in pairs(Shot.bodies) do
			if base.collides(s.position, self.size, v.position, v.size) then
				v.collides = true
				v.explosionEffect = i ~= self.first
				if i == self.first and self.vulnerable then
					addscore(20)
					self.first = self.first + 1
					s.size = self.size
					neweffects(s, 20)
					if self.first > self.last then self.delete = true
					else 
						self.position = self.segments[self.first].position
						if self.vulnerable then
							self.leadchange:setAndGo(0, 130, 130/self.timeout)
							self.vulnerable = false
						end
					end
				end
			end
		end

		if psycho.canbehit and not gamelost and base.collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.diereason = "shot"
			lostgame()
		end

		if (s.position.x + self.size < 0 and s.speed.x <= 0) or (s.position.x > width + self.size and s.speed.x >= 0) or
			(s.position.y + self.size < 0 and s.speed.y <= 0) or (s.position.y > height + self.size and s.speed.y >= 0) then
			self.first = self.first + 1
			s.size = self.size
			neweffects(s, 20)
			if self.first > self.last then self.delete = true
			else self.position = self.segments[self.first].position end
		elseif s.target then
			local curdist = s.position:distsqr(self.path[s.target])
			if curdist < 1 or curdist > s.prevdist then
				s.position:set(self.path[s.target])
				s.target = s.target + 1
				local prev = self.segments[i - 1]
				if prev and prev.target == s.target then s.position:set(prev.position):sub(prev.speed:normalized():mult(self.considersize*2)) end
				if s.target > #self.path then s.prevdist = nil s.target = nil
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

function snake:onInit( n, spd, timeout, p1, p2, ... )
	if not n then return end
	n = n or snake.segmentsN
	self.timeout = timeout or 1.5
	self.segmentsN = n
	self.segments = {}
	self.path = clone {p2, ...}
	self.position = Vector:new(base.clone(p1))
	self.speedvalue = spd or v
	self.leadchange = VarTimer:new{var = 130, alsoCall = function() self.vulnerable = true end}
	self.coloreffect = ColorManager.ColorManager.getColorEffect({var = 122}, {var = 122}, {var = 122}, self.leadchange)
	local speed = Vector:new(base.clone(p2)):sub(self.position):normalize()
	self.considersize = self.considersize or self.size
	local diff = speed * (self.considersize*2)
	speed:mult(spd or v*.8, spd or v*.8)
	self.speed = speed:clone()
	self.first, self.last = 1, n
	self.segments[1] = { speed = speed, position = self.position, prevdist = self.position:distsqr(p2), target = 1 }
	for i = 2, n, 1 do
		local s = {}
		s.speed = speed:clone()
		s.position = self.position - ((i - 1)*diff)
		s.prevdist = s.position:distsqr(p2)
		s.target = 1
		self.segments[i] = s
	end
end

function snake:start()
	Body.start(self)
	if not self.vulnerable then
		self.coloreffect = ColorManager.noLSDEffect
	end
end