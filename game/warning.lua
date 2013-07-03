warning = body:new {
	mode = 'line',
	piece = .15,
	lineWidth = 1,
	bodies = {},
	__type = 'warning'
}

function warning:__init()
	if self.based_on then
		self.arctan = math.atan(self.based_on.Vy/ self.based_on.Vx) + (self.based_on.Vx < 0 and math.pi or 0)
		self.size = self.based_on.size*2
		self.position = self.based_on.position
		self.variance = self.based_on.variance
		self.coloreffect = self.based_on.coloreffect
		self.alpha = self.based_on.alpha
		self.alphafollows = self.based_on.alphafollows
		self.based_on = nil
	end
end

function warning:draw()
	graphics.setLine(self.lineWidth)
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.arc(self.mode, self.position[1], self.position[2], self.size, self.arctan - self.piece, self.arctan + self.piece)
end