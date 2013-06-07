circleEffect = body:new {
	alpha = 10,
	maxsize = width / 1.9,
	mode = 'line',
	__type = 'circle',
	bodies = {}
}

function circleEffect:__init()
	if self.based_on then --circle to be based on
		self.position = self.based_on.position:clone{}
		self.size = self.based_on.size
		self.based_on = nil
	end
	
	self.sizeGrowth = self.sizeGrowth or math.random(120, 160)		
	self.variance = self.variance or math.random(0, 10*colortimer.timelimit) / 10
	if #circleEffect.bodies > 250 then table.remove(circleEffect.bodies, 1) end
	if self.index ~= nil then
		if self.index ~= false then
			circleEffect.bodies[self.index] = self
		end
	else
		table.insert(circleEffect.bodies, self)
	end
end

function circleEffect.init()
	circleEffect.timer = timer:new{
		timelimit = .2,
		running = true,
		persistent = true
	}

	function circleEffect.timer:funcToCall() -- releases cirleEffects
		if not gamelost then
			circleEffect:new {
				based_on = psycho
			}
		end
		for i,v in pairs(enemy.bodies) do
			if v.size == 15 and math.random() < .5 --[[reducing chance]] then 
				circleEffect:new{
					based_on = v
				} 
			end
		end
	end
end

function circleEffect:draw()
	if self.linewidth then love.graphics.setLine(self.linewidth) end
	love.graphics.setColor(color(self.color, colortimer.time + self.variance, self.alpha))
	love.graphics.circle(self.mode, self.x, self.y, self.size)
	if self.linewidth then love.graphics.setLine(4) end
end

function circleEffect:update(dt)
	self.size = self.size + self.sizeGrowth * dt
	self.delete = self.size < 0 or self.size > self.maxsize
end