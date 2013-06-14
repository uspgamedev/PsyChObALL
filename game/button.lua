button = body:new {
	text = '',
	fontsize = 12,
	onHover = false,
	__type = 'button',
	bodies = {}
}

function button:__init()
	if self.menu and self.menu < 10 then
		self.position:add((self.menu - 1)*width)
	end
	self.menu = self.menu or mainmenu
	self:setText(self.text)
	self.effectsBurst = timer:new {
		timelimit = .1,
		pausable = false,
		persistent = true
	}
	function self.effectsBurst.funcToCall(timer)
		neweffects(self, 2)
	end

	self.hoverring = circleEffect:new {
		size = .1,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 3,
		position = self.position,
		index = false
	}
end

function button:draw()
	self.alpha = alphatimer.var
	--body.draw(self)
	graphics.setColor(inverteffect(maincolor))
	graphics.setFont(getCoolFont(self.fontsize))
	graphics.printf(self.text, self.ox, self.oy, self.size*2, 'center')
end

function button:update( dt )
	if self.hoverring.size > self.size then
		self.hoverring.size = self.size
		self.hoverring.sizeGrowth = 0
	end
	if self.menu ~= state then
		if self.onHover then 
			self.onHover = false
			self:hover(false)
		end
		return
	end
	if self.onHover ~= ((mouseX - self.x)^2 + (mouseY - self.y)^2 < self.size^2) then
		self.onHover = not self.onHover
		self:hover(self.onHover)
	end
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

function button:close()
	if self.onHover then 
		self.onHover = false
		self:hover(false)
	end
end

function button:hover(hovering)
	if hovering then
		self.effectsBurst:start(.2)
		self.hoverring.size = 0
		self.hoverring.sizeGrowth = 350
		circleEffect.bodies[self] = self.hoverring
	else
		self.effectsBurst:stop()
		self.hoverring.sizeGrowth = -350
	end
end

function button.mousepressed( x, y, btn )
	for k, b in pairs(button.bodies) do
		if ((x-b.x)^2 + (y-b.y)^2) < b.size^2 then
			b:pressed()
		end
	end
end

function button.mousereleased( x, y, btn )
	-- body
end