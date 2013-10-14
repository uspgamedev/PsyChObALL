ControlsMenu = Menu:new {
	index = tutorialmenu
}

function ControlsMenu:open()
	Menu.open(self)

	local backbutton = Button:new {
		size = 80,
		position = Vector:new {100, height - 100},
		text = "Back",
		fontsize = 20,
		pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('right/left', -1)) end
	}

	self:addComponent(backbutton)
end

function ControlsMenu:draw()
	Menu.draw(self)

	graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time*.25 + 3))
	graphics.setFont(Base.getCoolFont(50))
	graphics.print("CONTROLS", 380, 36)
	graphics.setFont(Base.getCoolFont(40))
	graphics.print("Survival Mode:", 170, 350)
	graphics.setColor(ColorManager.getComposedColor(1))
	graphics.setFont(Base.getCoolFont(20))
	graphics.print("You get points when", 540, 425)
	graphics.print("  you kill an enemy", 570, 455)
	graphics.print("Survive as long as you can!", 152, 440)
	graphics.print("You get one more ulTrAbLaST for every 30 seconds you survive!", 182, 500)
	graphics.print("You have a limited amount of ulTrAbLaSTs to use", 540, 230)
	graphics.print("You get one more ulTrAbLaST for every 1000 points!", 540, 270)
	graphics.setFont(Base.getCoolFont(20))
	graphics.print("Use WASD or arrows to move", 152, 170)
	graphics.print("Click or hold the left mouse button to shoot", 540, 170)
	graphics.print("Hold space to charge", 70, 252)
	graphics.setFont(Base.getCoolFont(35))
	graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time * 0.144))
	graphics.print("ulTrAbLaST", 290, 242)

	graphics.setPixelEffect(Base.circleShader)
	graphics.setColor(ColorManager.getComposedColor(6))
	graphics.circle("fill", 130, 180, 10)
	graphics.circle("fill", 520, 450, 10)
	graphics.circle("fill", 160, 510, 10)
	graphics.circle("fill", 520, 240, 10)
	graphics.circle("fill", 520, 280, 10)
	graphics.circle("fill", 520, 180, 10)
	graphics.circle("fill", 130, 450, 10)
	graphics.circle("fill", 50, 263, 10)
	graphics.setPixelEffect()
end