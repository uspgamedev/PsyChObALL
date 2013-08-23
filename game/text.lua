text = body:new {
	text = 'notext',
	size = 20,
	ord = 6,
	printmethod = graphics.print,
	bodies = {}
}

function text:__init()
	self.font = self.font or getFont(self.size)
	self.variance = rawget(self, 'variance') or math.random(colorcycle*1000)/1000
end

function text:draw()
	if (self.alpha or self.alphafollows and self.alphafollows.var) == 255 then print 'asdf' end
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.setFont(self.font)
 	self.printmethod(self.text, self.position[1], self.position[2], self.limit, self.align)
end