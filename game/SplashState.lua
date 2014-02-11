require 'base.State'

SplashState = State:new {}

local image

function SplashState:create()
	image = graphics.newImage 'resources/Marvellous Soft.png'
	Timer:new{ 
		timelimit = 1.75,
		funcToCall = function() Game.switchState(MenuManager) end, 
		onceOnly = true, 
		running = true,
		pausable = false
	}
end

function SplashState:draw()
	graphics.setColor(255, 255, 255, 255)
	graphics.rectangle("fill", 0, 0, width, height) -- background color
	graphics.draw(image, 100, 80, 0, .55, .55)
	State.draw(self)
end

function SplashState:destroy()
	image = nil
end