MenuTransition = lux.object.new {
	__type = 'MenuTransition'
}

function MenuTransition:begin()
	self.inCommonDrawables = {}
	if not MenuManager.previousMenu or not MenuManager.currentMenu then return end
	for drawable in pairs(MenuManager.previousMenu.drawableParts) do
		if MenuManager.currentMenu.drawableParts[drawable] then
			self.inCommonDrawables[drawable] = true
		end
	end
end

function MenuTransition:drawPrevious()
	MenuManager.previousMenu:draw()
	for drawFunc in pairs(MenuManager.previousMenu.drawableParts) do
		if not self.inCommonDrawables[drawFunc] then drawFunc() end
	end
end

function MenuTransition:drawCurrent()
	MenuManager.currentMenu:draw()
	for drawFunc in pairs(MenuManager.currentMenu.drawableParts) do
		if not self.inCommonDrawables[drawFunc] then drawFunc() end
	end
end

function MenuTransition:drawExtra()
	for drawFunc in pairs(self.inCommonDrawables) do
		drawFunc()
	end
end

function MenuTransition:close()
	MenuManager.currentTransition = nil
	self.inCommonDrawables = nil
end

MenuTransitions = {} -- list of transitions

MenuTransitions.Cut = MenuTransition:new{}

function MenuTransitions.Cut:begin()
	if MenuManager.currentMenu then MenuManager.currentMenu.alphaFollows.var = 255 end
	if MenuManager.previousMenu then
		MenuManager.previousMenu:close()
		MenuManager.previousMenu = nil
	end
	MenuManager.currentTransition = nil	
end

MenuTransitions.Fade = MenuTransition:new{
	fadeSpeed = 170
}

function MenuTransitions.Fade:begin()
	MenuTransition.begin(self)
	if MenuManager.previousMenu then MenuManager.previousMenu.alphaFollows:setAndGo(255, 1, self.fadeSpeed) end
	if MenuManager.currentMenu then MenuManager.currentMenu.alphaFollows:setAndGo(0, 254, self.fadeSpeed) end
end

function MenuTransitions.Fade:drawPrevious()
	if MenuManager.previousMenu.alphaFollows.var == 1 then
		MenuManager.previousMenu:close()
		--delete it when it completely fades out
		MenuManager.previousMenu = nil
	else 
		MenuTransition.drawPrevious(self)
	end
end

function MenuTransitions.Fade:drawCurrent()
	MenuTransition.drawCurrent(self)
	if not MenuManager.previousMenu and MenuManager.currentMenu.alphaFollows.var == 254 then
		self:close()
	end
end

MenuTransitions.Slide = MenuTransition:new{
	slideSpeed = width/.5,
	direction = 1 -- 1 = left/rigth
}

local translateFuncs = {
	['right/left'] = function(t) graphics.translate(t, 0) end,
	['up/down'] = function(t) graphics.translate(0, t) end,
	diagonal1 = function(t) graphics.translate(t, t) end,
	diagonal2 = function(t) graphics.translate(-t, t) end
}

function MenuTransitions.Slide:begin()
	MenuTransition.begin(self)
	self.slideTimer = VarTimer:new{var = 0, pausable = false}
	self.slideTimer:setAndGo(0, Base.sign(self.slideSpeed) * width, math.abs(self.slideSpeed))
	self.translateFunc = translateFuncs[self.direction]
	self.slideTimer.alsoCall = function() 
		self.slideTimer = nil
		self.translateFunc = nil
		self:close()
	end
end

function MenuTransitions.Slide:drawPrevious()
	self.translateFunc(-self.slideTimer.var, 0)
	MenuTransition.drawPrevious(self)
	self.translateFunc(self.slideTimer.var, 0)
end

function MenuTransitions.Slide:drawCurrent()
	self.translateFunc(-self.slideTimer.var + Base.sign(self.slideTimer.var) * width, 0)
	MenuTransition.drawCurrent(self)
	self.translateFunc(self.slideTimer.var - Base.sign(self.slideTimer.var) * width, 0)
end

function MenuTransitions.Slide:setDir( dir, mult )
	self.direction = dir
	self.slideSpeed = math.abs(self.slideSpeed) * mult
	return self
end