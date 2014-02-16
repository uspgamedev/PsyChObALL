require 'AdventureState'

MainMenu = Menu:new {
	index = 1
}

function MainMenu:load()
	Menu.load(self)

	local playButton = Button:new{
		size = 120,
		position = Vector:new {width/2 + 200, 430},
		text = 'Survival',
		fontsize = 40
	}

	function playButton:pressed()
		self.visible = false
		Effect.createEffects(self, 50)
		MenuManager:changeToMenu(nil, MenuTransitions.Fade)
		if not filesystem.exists 'config' then
			FileManager.writeConfig()
			AdventureState:runLevel('Tutorial')
		else
			Game.switchState(SurvivalState)
		end
	end


	local storyButton = Button:new {
		size = 120,
		position = Vector:new {width/2 - 200, 430},
		text = 'Adventure',
		fontsize = 40
	}

	function storyButton:pressed()
		self.visible = false
		Effect.createEffects(self, 50)
		MenuManager:changeToMenu(nil, MenuTransitions.Fade)
		if not filesystem.exists 'config' then
			FileManager.writeConfig()
			AdventureState:runLevel('Tutorial')
		else
			AdventureState:runLevel('Level 1-1')
		end
	end


	local controlsButton = Button:new {
		size = 80,
		position = Vector:new {width - 100, height - 100},
		text = "Controls",
		fontsize = 20,
		pressed = function() MenuManager:changeToMenu(ControlsMenu, MenuTransitions.Slide:setDir('right/left', 1)) end
	}

	local testingButton = Button:new {
		size = 50,
		position = Vector:new{width/2, height - 100},
		text = "Practice",
		fontsize = 15,
		pressed = function() MenuManager:changeToMenu(PracticeMenus[1], MenuTransitions.Slide:setDir('up/down', 1)) end
	}

	local recordsButton = Button:new {
		size = 80,
		position = Vector:new {100, height - 100},
		text = "Stats",
		fontsize = 20,
		pressed = function() MenuManager:changeToMenu(RecordsMenu, MenuTransitions.Slide:setDir('right/left', -1)) end
	}

	for _, component in ipairs {playButton, testingButton, storyButton, controlsButton, recordsButton} do
		self:add(component)
	end
end

function MainMenu:draw()
	Menu.draw(self)
	graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time * 0.144, MainMenu.alphaFollows.var))
	graphics.setFont(Base.getFont(12))
	graphics.print("v" .. version, width/2 - 10, 685)
	graphics.print('Write "reset" to delete stats', 15, 10)
	if UI.resetted then graphics.print("~~stats deleted~~", 25, 23) end

	if oldVersion then
		graphics.print("Version " .. latest, 422, 700)
		graphics.print("is available to download!", 510, 700)
	end
	graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)

	graphics.setFont(Base.getCoolFont(24))
	if Cheats.konamicode then
		graphics.print("KONAMI CODE!", 450, 5)
	end
	graphics.setFont(Base.getFont(30))

	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time * 2.5 + 1, MainMenu.alphaFollows.var))
	graphics.draw(logo, (width - logo:getWidth()/4)/2, 75, nil, 0.25, 0.20)
	graphics.setFont(Base.getFont(12))
end