require "menus.Menu"
require "menus.MenuTransitions"
require 'base.State'

MenuManager = State:new {}

local newMenu, newTransition = false, nil

function MenuManager.init()
	for _, menu in ipairs {"Controls", "Main", "Practice", "Records"} do
		require('menus.' .. menu .. 'Menu')
	end
end

function MenuManager:create()
	resetVars()
	for _, added in ipairs {CircleEffect, Text, Effect} do
		self:add(added.bodies)
	end
end

function MenuManager:draw()
	State.draw(self)
	if self.currentTransition then
		if self.previousMenu then self.currentTransition:drawPrevious() end
		if self.currentMenu and self.currentTransition then self.currentTransition:drawCurrent() end
		if self.currentTransition then self.currentTransition:drawExtra() end
	else
		if self.currentMenu then self.currentMenu:completeDraw() end
	end
end

function MenuManager:update( dt )
	if newMenu then
		if self.previousMenu then self.previousMenu:close() end
		self.previousMenu = self.currentMenu
		self.currentMenu = newMenu
		if newMenu then newMenu:load() end
		self.currentTransition = newTransition or MenuTransitions.Cut
		self.currentTransition:begin()
		newMenu, newTransition = false, nil
	end

	State.update(self, dt)
	if self.previousMenu then self.previousMenu:update(dt) end
	if self.currentMenu then self.currentMenu:update(dt) end
end

function MenuManager:changeToMenu( menu, transition )
	newMenu = menu
	newTransition = transition
end

function MenuManager:destroy()
	if self.currentMenu then self.currentMenu:close() end
	if self.previousMenu then self.previousMenu:close() end
	self.currentMenu = nil
	self.previousMenu = nil
	self.currentTransition = nil
	State.destroy(self)
end

function MenuManager:mousePressed( x, y, btn )
	if self.currentMenu then self.currentMenu:mousePressed(x, y, btn) end
end