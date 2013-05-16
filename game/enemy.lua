require 'body'

enemy = body:new {
	collides = false,
	diereason = 'leftscreen',
	mode = 'fill',
	size = 15,
	__type = 'enemy'
}

function enemy:__init()
	local side = math.random(4)
	if		side == 1 then --top
		self.x = math.random(15, love.graphics.getWidth() - self.size - 1)
		self.y = 1
		self.Vy = math.random(v, v + 50)
		local n = -1
		if self.x < love.graphics.getWidth() / 2 then n = 1 end
		self.Vx = n * math.random(0, v)
	elseif	side == 2 then --bottom
		self.x = math.random(15, love.graphics.getWidth() - self.size - 1)
		self.y = love.graphics.getHeight()-1
		self.Vy = -math.random(v, (v + 50))
		local n = -1
		if self.x < love.graphics.getWidth() / 2 then n = 1 end
		self.Vx = n * math.random(0, v)
	elseif	side == 3 then --left
		self.x = 1
		self.y = math.random(15, love.graphics.getHeight() - self.size - 1)
		self.Vx = math.random(v, v + 50)
		local n = -1
		if self.y < love.graphics.getHeight() / 2 then n = 1 end
		self.Vy = n * math.random(0, v)
	elseif side == 4 then --right
		self.x = love.graphics.getWidth() - 1
		self.y = math.random(15, love.graphics.getHeight() - self.size - 1)
		self.Vx = -math.random(v, v + 50)
		local n = -1
		if self.y < love.graphics.getHeight() / 2 then n = 1 end
		self.Vy = n * math.random(0, v)
	end

	self.variance = math.random(colortimer.timelimit * 1000) / 1000
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
				song:setPitch(1.5)
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
		if self.size >= 15 then addscore(-4 * multiplier) end
		neweffects(self, 4)
	end

	if self.size >= 10 then 
		for i = 1,3 do
			local e = enemy:new{
				size = self.size - 5
			}
			e.x = self.x
			e.y = self.y
			e.Vx = math.random(v)-v / 2 + 1.3 * self.Vx
			e.Vy = math.random(v)-v / 2 + 1.3 * self.Vy
			if e.Vy + e.Vx < 10 then e.Vy = signum(self.Vy) * math.random(3 * v / 4, v) end
			e.variance = self.variance
			table.insert(enemy.bodies, e)
		end
	end
end

function enemy:draw()
	love.graphics.setColor(color(self.color, colortimer.time + self.variance))
	love.graphics.circle(self.mode, self.position[1], self.position[2], self.size)
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

	return not(self.collides or self.x < -self.size or self.y < -self.size or self.x - self.size > width or self.y - self.size > height)
end
