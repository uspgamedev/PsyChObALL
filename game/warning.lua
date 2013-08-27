Warning = Body:new {
	mode = 'line',
	piece = .15,
	lineWidth = 1,
	angle = 0,
	spriteBatch = false,
	bodies = {},
	__type = 'Warning'
}

Body.makeClass(Warning)

function Warning:__init()
	if self.based_on then
		self.angle = math.atan2(self.based_on.Vy, self.based_on.Vx)
		self.size = self.based_on.size*2
		self.position = base.restrainInScreen(self.based_on.position:clone())
		self.variance = self.based_on.variance
		self.coloreffect = self.based_on.coloreffect
		self.alpha = self.based_on.alpha
		self.alphafollows = self.based_on.alphafollows
	end
end

function Warning:recalc_angle()
	self.angle = math.atan2(self.based_on.Vy, self.based_on.Vx)
end

function Warning:draw()
	graphics.setLine(self.lineWidth)
	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.arc(self.mode, self.position[1], self.position[2], self.size, self.angle - self.piece, self.angle + self.piece)
end