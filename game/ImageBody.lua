ImageBody = Body:new {
	image = nil,
	bodies = Group:new{},
	scale = 1,
	mode = 'none',
	__type = 'ImageBody'
}

Body.makeClass(ImageBody)

function ImageBody:revive()
	Body.revive(self)

	self.image = ImageBody.image
	self.scale = ImageBody.scale
	self.coloreffect = nil

	return self
end

function ImageBody:start()
	assert(self.image, 'ImageBody needs an image!')
	self.size = math.max(self.image:getWidth(), self.image:getHeight())*self.scale
end

function ImageBody:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect))
	graphics.draw(self.image, self.position[1], self.position[2], 0, self.scale, self.scale)
end