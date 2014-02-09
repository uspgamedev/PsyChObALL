require "menus.Menu"
require "menus.MenuTransitions"

module('MenuManager', package.seeall)

function init()
	currentMenu = nil
	previousMenu = nil
	currentTransition = nil

	for _, menu in ipairs {"Controls", "Main", "Practice", "Records"} do
		require('menus.' .. menu .. 'Menu')
	end
end

function draw()
	if currentTransition then
		if previousMenu then currentTransition:drawPrevious() end
		if currentMenu and currentTransition then currentTransition:drawCurrent() end
		if currentTransition then currentTransition:drawExtra() end
	else
		if currentMenu then currentMenu:completeDraw() end
	end
end

function update( dt )
	if previousMenu then previousMenu:update(dt) end
	if currentMenu then currentMenu:update(dt) end
end

function changeToMenu( menu, transition )
	if previousMenu then previousMenu:close() end
	previousMenu = currentMenu
	currentMenu = menu
	if menu then menu:load() end
	currentTransition = transition or MenuTransitions.Cut
	currentTransition:begin()
end