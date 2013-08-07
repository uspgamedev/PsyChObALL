imagebody = body:new {
	image = nil,
	bodies = {},
	scale = 1,
	__type = 'imagebody'
}

function imagebody:__init()
	assert(self.image, 'imagebody needs an image!')
	self.size = math.max(self.image:getWidth(), self.image:getHeight())*self.scale
end

function imagebody:draw()
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.draw(self.image, self.position[1], self.position[2], 0, self.scale, self.scale)
end