Enemy = Body:new {
	causeOfDeath = 'leftscreen',
	size = 16,
	shader = Base.circleShader,
	bodies = Group:new{},
	__type = 'Enemy'
}

Body.makeClass(Enemy)

local sides = {top = 1, up = 1, bottom = 2, down = 2, left = 3, right = 4}

local random = math.random
function Enemy:revive( randomize )
	Body.revive(self)

	self.size = Enemy.size
	self.causeOfDeath = Enemy.causeOfDeath

	if randomize ~= false then -- nil defaults to true
		self.variance = random() * ColorManager.colorCycleTime
		self:randomizePosition()
	end

	return self
end

function Enemy:randomizePosition()
	self.variance = random() * ColorManager.colorCycleTime
	self.speed:set(0, 0)

	local side = self.side and sides[self.side] or random(4)
	if	side == 1 or side == 2 then -- top or bottom
		self.x = random(self.size, width - self.size)
		self.y = side == 1 and 0 or height
		self.Vy = random(v, v + 50) * (side == 1 and 1 or -1)
		local n = -1
		if self.x < width / 2 then n = 1 end
		self.Vx = n * random(0, v)
	elseif side == 3 or side == 4 then -- left or right
		self.x = side == 3 and 0 or width
		self.y = random(self.size, height - self.size)
		self.Vx = random(v, v + 50) * (side == 3 and 1 or -1)
		local n = -1
		if self.y < height / 2 then n = 1 end
		self.Vy = n * random(0, v)
	end
end

function Enemy:kill()
	Body.kill(self)

	if self.causeOfDeath == "shot" then
		RecordsManager.addScore(self.size / 3)
		Effect.createEffects(self, self.size + 7)
		RecordsManager.addMultiplier(self.size / 30)

		if self.size >= 15 then
			local c = CircleEffect.bodies:getFirstDead():revive(self)
			c.lineWidth = 7
			c.alpha = 80
			c.sizeGrowth = 600
			c.maxSize = width
		end

		if self.size >= 10 then
			local times = self.size >= 15 and 3 or 2
			local size  = self.size >= 15 and self.size/3 + 5 or 6
			local enemies = Enemy.bodies:getObjects(times)
			for i = 1, times do
				local e = enemies[i]:revive(false)
				e.size = size
				
				e.position:set(self.position):add(random(self.size), random(self.size))
				e.speed:set(self.speed):add((random() - .5)*v*1.9, (random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)

				if e.Vy + e.Vx < 10 then e.Vy = Base.sign(self.Vy) * random(3 * v / 4, v) end

				e.variance = self.variance
				e:register()
			end
		end
	else
		Effect.createEffects(self, 15)
	end	
end

function Enemy:update(dt)
	Body.update(self, dt)

	Shot.bodies:forEachAlive(function(shot)
		if self.alive and self:collidesWith(shot) then
			self.causeOfDeath = "shot"
			self:kill()
			shot.explosionEffects = false
			shot:kill()
		end
	end)

	if not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

end
