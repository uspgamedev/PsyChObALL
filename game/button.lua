button = body:new {
	text = '',
	fontsize = 12,
	onHover = false,
	__type = 'button',
	visible = true,
	bodies = {},
	allbuttons = {}
}
setmetatable(button.allbuttons, {__mode = 'v'})

function button:__init()
	if self.menu and self.menu < 10 then
		self.position:add((self.menu - 1)*width)
	end

	self.variance = math.random(ColorManager.cycleTime * 1000)/1000
	self.menu = self.menu or mainmenu
	self:setText(self.text)
	self.effectsBurst = timer:new {
		timelimit = .07,
		pausable = false,
		registerSelf = false,
		persistent = true
	}

	function self.effectsBurst.funcToCall(timer)
		neweffects(self, 1)
	end

	self.hoverring = circleEffect:new {
		size = .1,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 3,
		position = self.position,
		alphafollows = self.alphafollows,
		index = false
	}

	table.insert(button.allbuttons, self)
end

function button:draw()
	if not self.visible or self.alphafollows.var == 0 then return end
	--body.draw(self)
	local color = ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect)
	graphics.setColor(color)
	graphics.setColor(ColorManager.invertEffect(color))
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
	self.text = t or self.text
	local font = getFont(self.fontsize/ratio)
	local dx, dy = font:getWrap(self.text, self.size*2)
	self.ox, self.oy = 
		self.x - self.size,
		self.y - font:getHeight()*dy/2
end

function button:pressed()
	print 'pressed'
end

function button:start()
	self.visible = nil
	self.effectsBurst:register()
end

function button:close()
	if self.onHover then
		self.onHover = false
		self:hover(false)
	end
	self.effectsBurst:remove()
end

function button:hover(hovering)
	if hovering then
		self.effectsBurst:start()
		self.hoverring.size = 0
		self.hoverring.sizeGrowth = 350
		self.hoverring.delete = false
		circleEffect.bodies[self] = self.hoverring
	else
		self.effectsBurst:stop()
		self.hoverring.sizeGrowth = -350
	end
end

function button:isClicked(x, y)
	return self.menu == state and ((x-self.x)^2 + (y-self.y)^2) < self.size^2
end

function button.mousepressed( x, y, btn )
	for k, b in pairs(button.allbuttons) do
		if b:isClicked(x, y) then
			b:pressed()
			return
		end
	end
end

function button.mousereleased( x, y, btn )
	-- body
end