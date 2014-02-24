Button = Body:new {
	text = '',
	fontsize = 12,
	onHover = false,
	__type = 'Button',
	visible = true
}

Body.makeClass(Button)

function Button:__init()
	self.variance = math.random(ColorManager.colorCycleTime * 1000)/1000
	self.menu = self.menu or mainmenu
	self:setText(self.text)
	self.effectsBurst = Timer:new {
		timeLimit = .07,
		pausable = false,
		registerSelf = false,
		persistent = true
	}

	function self.effectsBurst.callback()
		Effect.createEffects(self, 1)
	end

	self.hoverring = Body.reviveAndCopy(CircleEffect.bodies:getFirstDead(), {
		size = .1,
		sizeGrowth = 0,
		alpha = 255,
		lineWidth = 3,
		alphaFollows = self.alphaFollows
	})

	self.hoverring.position:set(self.position)

	self.hoverring.update = function(self, dt)
		self.size = self.size + self.sizeGrowth * dt
	end
end

function Button:draw()
	if not self.visible or self.alphaFollows.var == 0 then return end
	local color = ColorManager.getComposedColor(self.variance, self.alpha or self.alphaFollows and self.alphaFollows.var, self.coloreffect)
	graphics.setColor(ColorManager.invertEffect(color))
	graphics.setFont(Base.getCoolFont(self.fontsize))
	graphics.printf(self.text, self.ox, self.oy, self.size * 2, 'center')
end

function Button:update( dt )
	if self.hoverring.size > self.size then
		self.hoverring.size = self.size
		self.hoverring.sizeGrowth = 0
	elseif self.hoverring.size <= 0 then
		self.hoverring.size = 0
		self.hoverring.sizeGrowth = 0
	end

	if self.menu ~= state or MenuManager.currentTransition then
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
	local font = Base.getFont(self.fontsize/ratio)
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

function Button:hover( hovering )
	if hovering then
		self.effectsBurst:start()
		self.hoverring.size = math.max(0, self.hoverring.size)
		self.hoverring.sizeGrowth = 350
	else
		self.effectsBurst:stop()
		self.hoverring.sizeGrowth = -350
	end
end

function Button:isClicked(x, y)
	return self.menu == state and not MenuManager.currentTransition and ((x-self.x)^2 + (y-self.y)^2) < self.size^2
end

function Button:mousePressed( x, y, btn )
	if btn == 'l' and self:isClicked(x, y) then
		self:pressed()
	end
end

function Button:mouseReleased( x, y, btn )
	
end

function Button:kill()
	Body.kill(self)

	self.hoverring.update = nil --restoring everything
	self.hoverring.alphaFollows = nil
	self.hoverring:kill()
	self.hoverring = nil
	self.alphaFollows = nil

	self.effectsBurst:remove()
end