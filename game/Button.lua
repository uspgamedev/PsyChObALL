Button = Body:new {
	text = '',
	fontsize = 12,
	onHover = false,
	__type = 'Button',
	visible = true,
	bodies = {},
	allbuttons = {}
}
setmetatable(Button.allbuttons, {__mode = 'v'})
Body.makeClass(Button)

function Button:__init()
	self.variance = math.random(ColorManager.colorCycleTime * 1000)/1000
	self.menu = self.menu or mainmenu
	self:setText(self.text)
	self.effectsBurst = Timer:new {
		timelimit = .07,
		pausable = false,
		registerSelf = false,
		persistent = true
	}

	function self.effectsBurst.funcToCall()
		neweffects(self, 1)
	end

	self.hoverring = CircleEffect:new {
		size = .1,
		sizeGrowth = 0,
		alpha = 255,
		linewidth = 3,
		position = self.position,
		alphaFollows = self.alphaFollows,
		index = false
	}

	table.insert(Button.allbuttons, self)
end

function Button:draw()
	if not self.visible or self.alphaFollows.var == 0 then return end
	local color = ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect)
	graphics.setColor(ColorManager.invertEffect(color))
	graphics.setFont(getCoolFont(self.fontsize))
	graphics.printf(self.text, self.ox, self.oy, self.size*2, 'center')
end

function Button:update( dt )
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

function Button:setText( t )
	self.text = t or self.text
	local font = getFont(self.fontsize/ratio)
	local dx, dy = font:getWrap(self.text, self.size*2)
	self.ox, self.oy = 
		self.x - self.size,
		self.y - font:getHeight()*dy/2
end

function Button:pressed()
	print 'pressed'
end

function Button:start()
	self.visible = nil
	self.effectsBurst:register()
end

function Button:close()
	if self.onHover then
		self.onHover = false
		self:hover(false)
	end
	self.effectsBurst:remove()
end

function Button:hover(hovering)
	if hovering then
		self.effectsBurst:start()
		self.hoverring.size = 0
		self.hoverring.sizeGrowth = 350
		self.hoverring.delete = false
		CircleEffect.bodies[self] = self.hoverring
	else
		self.effectsBurst:stop()
		self.hoverring.sizeGrowth = -350
	end
end

function Button:isClicked(x, y)
	return self.menu == state and ((x-self.x)^2 + (y-self.y)^2) < self.size^2
end

function Button.mousepressed( x, y, btn )
	for k, b in pairs(Button.allbuttons) do
		if b:isClicked(x, y) then
			b:pressed()
			return
		end
	end
end

function Button.mousereleased( x, y, btn )
	
end