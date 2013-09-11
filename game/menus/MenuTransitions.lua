MenuTransition = lux.object.new {
	begin = Base.doNothing,
	__type = 'MenuTransition'
}

function MenuTransition:drawPrevious()
	MenuManager.previousMenu:draw() -- just draw it
end

function MenuTransition:drawCurrent()
	MenuManager.currentMenu:draw() -- just draw it
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
	if MenuManager.previousMenu then MenuManager.previousMenu.alphaFollows:setAndGo(255, 1, self.fadeSpeed) end
	if MenuManager.currentMenu then MenuManager.currentMenu.alphaFollows:setAndGo(0, 254, self.fadeSpeed) end
end

function MenuTransitions.Fade:drawPrevious()
	if MenuManager.previousMenu.alphaFollows.var == 1 then
		MenuManager.previousMenu:close()
		--delete it when it completely fades out
		MenuManager.previousMenu = nil
		MenuManager.currentTransition = nil
	else 
		MenuManager.previousMenu:draw()
	end
end

function MenuTransitions.Fade:drawCurrent()
	MenuManager.currentMenu:draw()
	if not MenuManager.previousMenu and MenuManager.currentMenu.alphaFollows.var == 254 then
		MenuManager.currentTransition = nil
	end
end

MenuTransitions.Slide = MenuTransition:new{
	slideSpeed = width/.6,
	direction = 1 -- 1 = left/rigth
}

local translateFuncs = {
	['right/left'] = function(t) graphics.translate(t, 0) end,
	['up/down'] = function(t) graphics.translate(0, t) end,
	diagonal1 = function(t) graphics.translate(t, t) end,
	diagonal2 = function(t) graphics.translate(-t, t) end
}

function MenuTransitions.Slide:begin()
	self.slideTimer = VarTimer:new{var = 0, pausable = false}
	self.slideTimer:setAndGo(0, Base.sign(self.slideSpeed) * width, math.abs(self.slideSpeed))
	self.translateFunc = translateFuncs[self.direction]
	self.slideTimer.alsoCall = function() 
		self.slideTimer = nil
		self.translateFunc = nil
		MenuManager.currentTransition = nil
	end
end

function MenuTransitions.Slide:drawPrevious()
	self.translateFunc(-self.slideTimer.var, 0)
	MenuManager.previousMenu:draw()
	self.translateFunc(self.slideTimer.var, 0)
end

function MenuTransitions.Slide:drawCurrent()
	self.translateFunc(-self.slideTimer.var + Base.sign(self.slideTimer.var) * width, 0)
	MenuManager.currentMenu:draw()
	self.translateFunc(self.slideTimer.var - Base.sign(self.slideTimer.var) * width, 0)
end

function MenuTransitions.Slide:setDir( dir, mult )
	self.direction = dir
	self.slideSpeed = math.abs(self.slideSpeed) * mult
	return self
end