local ipairs, require, print = ipairs, require, print
local MenuManager = {}
setfenv(1, MenuManager)

require "menus.Menu"
require "menus.MenuTransitions"


function init()
	currentMenu = nil
	previousMenu = nil
	currentTransition = nil

	for _, menu in ipairs {"Controls", "Main", "Practice"} do
		MenuManager[menu .. 'Menu'] = require('menus.' .. menu .. 'Menu')
	end
end

function draw()
	if currentTransition then
		if previousMenu then currentTransition:drawPrevious() end
		if currentTransition and currentMenu then currentTransition:drawCurrent() end
	else
		if currentMenu then currentMenu:draw() end
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
	if menu then menu:open() end
	currentTransition = transition or MenuTransitions.Cut
	currentTransition:begin()
end

return MenuManager