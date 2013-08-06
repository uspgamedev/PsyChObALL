text = body:new {
	text = 'notext',
	size = 20,
	bodies = {}
}

function text:__init()
	self.font = self.font or getFont(self.size)
	self.variance = math.random(colorcycle*1000)/1000
end

function text:draw()
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.setFont(self.font)
	graphics.print(self.text, self.position[1], self.position[2])
end