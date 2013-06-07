enemy = body:new {
	collides = false,
	diereason = 'leftscreen',
	size = 16,
	__type = 'enemy',
	bodies = {}
}

function enemy:__init()
	local side = math.random(4)
	if	side == 1 or side == 2 then -- top or bottom
		self.x = math.random(15, width - self.size - 1)
		self.y = side == 1 and 1 or height - 1
		self.Vy = math.random(v, v + 50) * (side == 1 and 1 or -1)
		local n = -1
		if self.x < width / 2 then n = 1 end
		self.Vx = n * math.random(0, v)
	elseif side == 3 or side == 4 then -- left or right
		self.x = side == 3 and 1 or width - 1
		self.y = math.random(15, height - self.size - 1)
		self.Vx = math.random(v, v + 50) * (side == 3 and 1 or -1)
		local n = -1
		if self.y < height / 2 then n = 1 end
		self.Vy = n * math.random(0, v)
	end

	self.variance = math.random(colortimer.timelimit * 1000) / 1000
end

function enemy.init()
	enemy.addtimer = timer:new {
		timelimit = 2,
		persistent = true
	}

	function enemy.addtimer:funcToCall() --adds the enemies to a list
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		enemylist:push(enemy:new{})
	end

	function enemy.addtimer:handlereset()
		self:stop()
	end

	enemy.releasetimer = timer:new {
		timelimit = 2,
		persistent = true
	}

	function enemy.releasetimer:funcToCall() --actually releases the enemies on screen
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		table.insert(enemy.bodies,enemylist:pop())
	end

	function enemy.releasetimer:handlereset()
		self:stop()
	end
end

function enemy:handleDelete()
	if self.diereason == "shot" then
		addscore((self.size / 3) * multiplier)
		neweffects(self, 23)
		multiplier = multiplier + (self.size / 30)

		if not  multtimer.running then  multtimer:start()
		else  multtimer.time = 0 end

		if  not gamelost and multiplier >= 10 and currentEffect ~= noLSDeffect then
			if not inverttimer.running then
				inverttimer:start()
				soundmanager.setPitch(1.1)
				timefactor = 1.1
				currentEffect = inverteffect
			else inverttimer.time = 0 end
		end

		if self.size >= 15 then 
			circleEffect:new{
				based_on = self,
				linewidth = 10,
				alpha = 100,
				sizeGrowth = 600, 
				maxsize = width
			} 
		end
	else
		neweffects(self, 4)
	end

	if self.size >= 10 then
		local times = self.size >= 15 and 3 or 2
		local size  = self.size >= 15 and self.size/3 + 5 or 6
		for i = 1, times do
			local e = enemy:new{
				size = size
			}
			e.position:set(self.position):add(math.random(self.size), math.random(self.size))
			e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
			if e.Vy + e.Vx < 10 then e.Vy = signum(self.Vy) * math.random(3 * v / 4, v) end
			e.variance = self.variance
			table.insert(enemy.bodies, e)
		end
	end
end

function enemy:update(dt)
	self.position:add(self.speed * dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	self.delete = self.delete or (self.collides or self.x < -self.size or self.y < -self.size or self.x - self.size > width or self.y - self.size > height)
end
