require 'base.State'

GameState = State:new {}

local function drawShootingDirection()
	if DeathManager.gameLost or psycho.pseudoDied then return end

	graphics.setLineWidth(1)
	local color = ColorManager.getComposedColor(2)
	graphics.setColor(color)
	if usingjoystick then
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local a1, a2 = joystick.getAxis(1, 4), joystick.getAxis(1, 5)
		if a1 == 0 and a2 == 0 then return end
		local x = a2 > 0 and width or 0
		-- Lazyness Warning: drawing a huge line to avoid having to think about the exact calculations!
		graphics.line(psycho.x, psycho.y, a2 * 1200 + psycho.x, a1 * 1200 + psycho.y) 
	else
		if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end
		graphics.circle("line", mouseX, mouseY, 5)
		color[4] = 60 -- alpha
		graphics.setColor(color)
		local x = mouseX > psycho.x and width or 0
		graphics.setPixelEffect()
		graphics.line(psycho.x, psycho.y, x, psycho.y + (x - psycho.x) * ((mouseY - psycho.y)/(mouseX - psycho.x)))
	end
	if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end
end

function GameState:draw()
	drawShootingDirection()


	--[[Drawing Game Objects]]
	--drawing psychoball
	if not Cheats.invisible then
		psycho:draw()
	end
	--[[End of Drawing Game Objects]]
	graphics.setPixelEffect()

	State.draw(self)
end
