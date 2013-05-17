require 'body'

shot = body:new {
	collides = false,
	mode 	 = 'fill',
	size 	 = 4,
	__type   = 'shot'
}

function shot:__init()
	self.variance = math.random(0, 100 * colortimer.timelimit) / 100
end

function shot:handleDelete()
	if not self.collides then neweffects(self, 7) end
end

function shot:draw()
	graphics.setColor(color(self.color, self.variance + colortimer.time))
    graphics.circle(self.mode, self.x, self.y, self.size)
end

function shot:update(dt)
    self.position:add(self.speed * dt)
    return not(self.collides or self.x < -self.size or self.y < -self.size or self.x + self.size > graphics.getWidth() or self.y + self.size > graphics.getHeight())
end