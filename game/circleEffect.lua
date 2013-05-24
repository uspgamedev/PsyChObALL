require 'body'

circleEffect = body:new {
	alpha = 10,
	maxsize = width / 1.9,
	mode = 'line',
	__type = 'circle'
}

function circleEffect:__init()
	if self.based_on then --circle to be based on
		self.position = self.based_on.position:clone{}
		self.size = self.based_on.size
		self.based_on = nil
	end
	
	self.sizeGrowth = self.sizeGrowth or math.random(120, 160)		
	self.variance = self.variance or math.random(30,300) / 100
	if #circleEffect.bodies > 250 then table.remove(circleEffect.bodies, 1) end
	if self.index then
		circleEffect.bodies[self.index] = self
		self.index = nil
	else
		table.insert(circleEffect.bodies, self)
	end
end

function circleEffect:draw()
    if self.linewidth then love.graphics.setLine(self.linewidth) end
    love.graphics.setColor(color(self.color, colortimer.time * self.variance, nil, self.alpha))
    love.graphics.circle(self.mode, self.x, self.y, self.size)
    if self.linewidth then love.graphics.setLine(4) end
end

function circleEffect:update(dt)
    self.size = self.size + self.sizeGrowth * dt
    
    self.delete = self.size < 0 or self.size > self.maxsize
end