PracticeMenu = Menu:new {}
local levelNumber = Levels.worldsNumber

function PracticeMenu:open( levelN )
	Menu.open(self)

	local back = Button:new{
		size = 50,
		position = Vector:new{width - 160, 580},
		text = "back",
		fontsize = 20
	}

	if levelN > 1 then
		back.pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('diagonal1', -1)) end
	else
		back.pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('up/down', -1)) end
	end

	local buttons = {back}

	if 'Level ' .. levelN .. '-4' < records.story.lastLevel then
		local nextB = Button:new{
			size = 50,
			position = Vector:new{width/2 + 100, 400},
			text = ">",
			fontsize = 55,
			pressed = function ()
				MenuManager.changeToMenu(PracticeMenus[levelN + 1], MenuTransitions.Slide:setDir('right/left', 1))
			end
		}
		buttons[#buttons + 1] = nextB
	end

	local goToLevelFunc = function (self)
		self.visible = false
		Effect.createEffects(self, 40)
		MenuManager.changeToMenu(nil, MenuTransitions.Fade)
		reloadStory(self.levelName, true)
		Levels.currentLevel.wasSelected = true
	end

	if levelN > 1 then
		local prevB = Button:new{
			size = 50,
			position = Vector:new{width/2 - 100, 400},
			text = "<",
			fontsize = 55,
			pressed = function ()
				MenuManager.changeToMenu(PracticeMenus[levelN - 1], MenuTransitions.Slide:setDir('right/left', -1))
			end
		}
		buttons[#buttons + 1] = prevB
	else
		local tut = Button:new{
			size = 60,
			position = Vector:new{width/2 - 30, height - 120},
			text = "Tutorial",
			levelName = "Tutorial",
			fontsize = 20,
			pressed = goToLevelFunc
		}
		buttons[#buttons + 1] = tut
	end

	for i = 1, 4 do
		local levelName = 'Level ' .. levelN .. '-' .. i
		if records.story.lastLevel < levelName or levelName == 'Level 1-4' then break end
		local levelButton = Button:new {
			size = 100,
			position = Vector:new{156 + (i-1) * 256, height/2 - 100},
			fontsize = 20,
			text = levelName,
			levelName = levelName,
			pressed = goToLevelFunc
		}
		buttons[#buttons + 1] = levelButton
	end

	for _, but in ipairs(buttons) do self:addComponent(but) end
end

function PracticeMenu:draw()
	Menu.draw(self)
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alphaFollows.var, self.coloreffect))
	graphics.setFont(Base.getCoolFont(70))
	graphics.printf("Practice", 0, 30, width, 'center')
end

PracticeMenus = {}

for i = 1, levelNumber do
	local menu = PracticeMenu:new{
		index = levelselect - 1 + i
	}
	menu.open = function(self) PracticeMenu.open(self, i) end
	PracticeMenus[i] = menu
end