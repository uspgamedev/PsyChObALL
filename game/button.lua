button = body:new {
	text = '',
	fontsize = 12,
	__type = 'button',
	bodies = {}
}

function button:__init()
	if self.menu and self.menu < 10 then
		self.position:add((self.menu - 1)*width)
	end
	self.menu = self.menu or mainmenu
	self:setText(self.text)
end

function button:draw()
	self.alpha = alphatimer.var
	body.draw(self)
	graphics.setColor(inverteffect(self.color))
	graphics.setFont(getFont(self.fontsize))
	graphics.printf(self.text, self.ox, self.oy, self.size*2, 'center')
end

function button:setText( t )
	self.text = t
	local font = getFont(self.fontsize)
	local dx, dy = font:getWrap(self.text, self.size*2)
	self.ox, self.oy = 
		self.x - self.size,
		self.y - font:getHeight()*dy/2
end

function button:pressed()
	print 'pressed'
end

function button.mousepressed( x, y, btn )
	for k, b in pairs(button.bodies) do
		if b.menu == state and ((x-b.x)^2 + (y-b.y)^2) < b.size^2 then
			b:pressed()
		end
	end
end

function button.mousereleased( x, y, btn )
	-- body
end