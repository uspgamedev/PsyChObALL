Text = Body:new {
	text = 'notext',
	size = 20,
	ord = 6,
	printFunction = graphics.print,
	__type = 'Text',
	mode = 'none',
	bodies = Group:new{}
}

Body.makeClass(Text)

function Text:revive()
	Body.revive(self)

	self.variance = math.random() * ColorManager.colorCycleTime
	self.font = Text.font
	self.printFunction = Text.printFunction
	self.limit = Text.limit
	self.align = Text.align
	self.alpha = nil
	self.speed:set(0, 0)

	return self
end

function Text:start()
	Body.start(self)
	self.font = self.font or Base.getFont(self.size)
end

function Text:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect))
	graphics.setFont(self.font)
 	self.printFunction(self.text, self.position[1], self.position[2], self.limit, self.align)
end