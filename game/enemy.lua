enemy = body:new {
	collides = false,
	diereason = 'leftscreen',
	size = 16,
	__type = 'enemy',
	bodies = {}
}

function enemy:__init()
	self.variance = math.random(colorcycle * 1000) / 1000

	local side = math.random(4)
	if	side == 1 or side == 2 then -- top or bottom
		self.x = math.random(self.size, width - self.size)
		self.y = side == 1 and 0 or height
		self.Vy = math.random(v, v + 50) * (side == 1 and 1 or -1)
		local n = -1
		if self.x < width / 2 then n = 1 end
		self.Vx = n * math.random(0, v)
	elseif side == 3 or side == 4 then -- left or right
		self.x = side == 3 and 0 or width
		self.y = math.random(self.size, height - self.size)
		self.Vx = math.random(v, v + 50) * (side == 3 and 1 or -1)
		local n = -1
		if self.y < height / 2 then n = 1 end
		self.Vy = n * math.random(0, v)
	end
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
		enemylist:pop():register()
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
				soundmanager.setPitch(1.03)
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
			if e.Vy + e.Vx < 10 then e.Vy = sign(self.Vy) * math.random(3 * v / 4, v) end
			e.variance = self.variance
			e:register()
		end
	end
end

function enemy:update(dt)
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end
