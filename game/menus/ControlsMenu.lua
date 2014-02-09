ControlsMenu = Menu:new {
	index = tutorialmenu
}

function ControlsMenu:load()
	Menu.load(self)

	local backButton = Button:new {
		size = 80,
		position = Vector:new {100, height - 100},
		text = "Back",
		fontsize = 20,
		pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('right/left', -1)) end
	}

	local forwardButton = Button:new {
		size = 50,
		fontsize = 55,
		text = '>',
		position = Vector:new {width/2 + 150, height - 100},
		pressed = function() MenuManager.changeToMenu(ControlsMenu2, MenuTransitions.Slide:setDir('right/left', 1)) end
	}	

	self:add(backButton)
	self:add(forwardButton)
end

function ControlsMenu.drawTitle()
	graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time*.25 + 3))
	graphics.setFont(Base.getCoolFont(50))
	graphics.printf("Controls", 0, 36, width, 'center')
end

function ControlsMenu.drawControls()
	graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time*.25 + 3))
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

ControlsMenu:addDrawablePart(ControlsMenu.drawTitle)
ControlsMenu:addDrawablePart(ControlsMenu.drawControls)

ControlsMenu2 = Menu:new { 
	index = tutorialmenu2
}

function ControlsMenu2:load()
	Menu.load(self)

	local backButton = Button:new {
		size = 50,
		fontsize = 55,
		text = '<',
		position = Vector:new {width/2 - 150, height - 100},
		pressed = function() MenuManager.changeToMenu(ControlsMenu, MenuTransitions.Slide:setDir('right/left', -1)) end
	}

	self:add(backButton)
end

ControlsMenu2:addDrawablePart(ControlsMenu.drawTitle)