PracticeMenu = Menu:new {}
local levelNumber = Levels.worldsNumber

function PracticeMenu:load( levelN )
	Menu.load(self)

	local back = Button:new{
		size = 50,
		position = Vector:new{width - 160, 580},
		text = "   ", -- actual text 'back' is displayed in drawTitleAndBack
		fontsize = 20
	}

	if levelN > 1 then
		back.pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('diagonal1', -1)) end
	else
		back.pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('up/down', -1)) end
	end

	self:add(back)

	if 'Level ' .. levelN .. '-4' < RecordsManager.records.story.lastLevel then
		local nextB = Button:new{
			size = 50,
			position = Vector:new{width/2 + 100, 550},
			text = " ", -- actual text '>' is displayed in drawRightArrow
			fontsize = 55,
			pressed = function ()
				MenuManager.changeToMenu(PracticeMenus[levelN + 1], MenuTransitions.Slide:setDir('right/left', 1))
			end
		}
		self:add(nextB)
		self:addDrawablePart(PracticeMenu.drawRightArrow)
	end

	local goToLevelFunc = function (self)
		self.visible = false
		Effect.createEffects(self, 40)
		MenuManager.changeToMenu(nil, MenuTransitions.Fade)
		reloadStory(self.levelName, true)
		--Levels.currentLevel.wasSelected = true
	end

	if levelN > 1 then
		local prevB = Button:new{
			size = 50,
			position = Vector:new{width/2 - 100, 550},
			text = " ", -- actual text '<' is displayed in drawLeftArrow
			fontsize = 55,
			pressed = function ()
				MenuManager.changeToMenu(PracticeMenus[levelN - 1], MenuTransitions.Slide:setDir('right/left', -1))
			end
		}
		self:add(prevB)
		self:addDrawablePart(PracticeMenu.drawLeftArrow)
	else
		local tut = Button:new{
			size = 60,
			position = Vector:new{width/2 - 30, height - 80},
			text = "Tutorial",
			levelName = "Tutorial",
			fontsize = 20,
			pressed = goToLevelFunc
		}
		self:add(tut)
	end

	self.titles = {}
	local minY = 2000
	for i = 1, 4 do
		local levelName = 'Level ' .. levelN .. '-' .. i
		if RecordsManager.records.story.lastLevel < levelName or levelName == 'Level 1-4' then break end

		local levelButton = Button:new {
			size = 70,
			position = Vector:new{156 + (i-1) * 256, height/2 + 50},
			fontsize = 20,
			text = levelName,
			levelName = levelName,
			pressed = goToLevelFunc
		}

		local t = Levels.levels[levelName].chapter
		local f = Base.getCoolFont(20)
		local _, lines = f:getWrap(t, 200)
		minY = math.min(minY, height/2 - 110 - lines * f:getHeight())
		self.titles[i] = {
			text = t,
			x = 55 + (i - 1) * 256,
			wrap = 200
		}

		self:add(levelButton)
	end

	for i = 1, 4 do
		if self.titles[i] then
			self.titles[i].y = minY
		end
	end
end

function PracticeMenu:close()
	Menu.close(self)
	self.drawableParts[PracticeMenu.drawRightArrow] = nil
	self.drawableParts[PracticeMenu.drawLeftArrow] = nil
end

local format = string.format
function PracticeMenu:draw( levelN )
	Menu.draw(self)

	graphics.setColor(ColorManager.getComposedColor(PracticeMenu.variance, PracticeMenu.alphaFollows.var, PracticeMenu.coloreffect))
	for i = 1, 4 do
		local levelName = 'Level ' .. levelN .. '-' .. i
		if RecordsManager.records.story.lastLevel < levelName or levelName == 'Level 1-4' then break end

		graphics.setFont(Base.getCoolFont(20))
		graphics.printf(self.titles[i].text, self.titles[i].x, self.titles[i].y, self.titles[i].wrap, "center")

		graphics.setFont(Base.getFont(15))
		graphics.print("Area High Score:", 90 + (i - 1) * 256, height/2 - 100)

		-- Actual Area High Score
		graphics.setFont(Base.getCoolFont(35))
		graphics.print(format("%.0f", RecordsManager.records.story[levelName].score), 120 + (i-1) * 256, height/2 - 85)
	end
end

function PracticeMenu.drawTitleAndBack()
	graphics.setColor(ColorManager.getComposedColor(PracticeMenu.variance, PracticeMenu.alphaFollows.var, PracticeMenu.coloreffect))

	graphics.setFont(Base.getCoolFont(70))
	graphics.printf("Practice", 0, 30, width, 'center')
	graphics.setFont(Base.getCoolFont(20))
	graphics.print("back", width - 182, 568)
end

function PracticeMenu.drawRightArrow()
	graphics.setColor(ColorManager.getComposedColor(PracticeMenu.variance, PracticeMenu.alphaFollows.var, PracticeMenu.coloreffect))
	graphics.setFont(Base.getCoolFont(55))
	graphics.print('>', width/2 + 85, 518)
end

function PracticeMenu.drawLeftArrow()
	graphics.setColor(ColorManager.getComposedColor(PracticeMenu.variance, PracticeMenu.alphaFollows.var, PracticeMenu.coloreffect))
	graphics.setFont(Base.getCoolFont(55))
	graphics.print('<', width/2 - 115, 518)
end

PracticeMenus = {}

for i = 1, levelNumber do
	local menu = PracticeMenu:new{
		index = levelselect - 1 + i
	}
	menu.load = function(self) PracticeMenu.load(self, i) end
	menu.draw = function(self)	PracticeMenu.draw(self, i) end
	menu:addDrawablePart(PracticeMenu.drawTitleAndBack)
	PracticeMenus[i] = menu
end