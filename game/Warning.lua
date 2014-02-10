Warning = Body:new {
	mode = 'line',
	piece = .15,
	lineWidth = 1,
	angle = 0,
	bodies = {},
	__type = 'Warning'
}

Body.makeClass(Warning)

local arctan = math.atan2
function Warning:__init()
	if self.based_on then
		self.angle = arctan(self.based_on.Vy, self.based_on.Vx)
		self.size = self.based_on.size*2
		self.position = Base.restrainInScreen(self.based_on.position:clone())
		self.variance = self.based_on.variance
		self.coloreffect = self.based_on.coloreffect
		self.alpha = self.based_on.alpha
		self.alphaFollows = self.based_on.alphaFollows
	end
end

function Warning:recalc_angle()
	self.angle = arctan(self.based_on.Vy, self.based_on.Vx)
end

function Warning:draw()
	graphics.setLine(self.lineWidth)
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect))
	graphics.arc(self.mode, self.position[1], self.position[2], self.size, self.angle - self.piece, self.angle + self.piece)
end