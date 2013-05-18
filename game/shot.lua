require 'body'

shot = body:new {
	collides = false,
	mode 	 = 'fill',
	size 	 = 4,
	color = {0,0,0,0},
	variance = 0,
	explosionEffects = true,
	__type   = 'shot'
}

function shot:handleDelete()
	if self.explosionEffects then neweffects(self, 7) end
	if not self.collides then neweffects(self, 7) end
end

function shot:draw()
	graphics.setColor(color(self.color, colortimer.time))
   graphics.circle(self.mode, self.x, self.y, self.size)
end

function shot:update(dt)
    self.position:add(self.speed * dt)
    self.delete = self.delete or (self.collides or self.x < -self.size or self.y < -self.size or self.x + self.size > width or self.y + self.size > height)
end