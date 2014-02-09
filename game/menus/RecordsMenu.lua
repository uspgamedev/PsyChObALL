RecordsMenu = Menu:new {
	index = recordsmenu
}

function RecordsMenu:load()
	Menu.load(self)

	local backButton = Button:new {
		size = 80,
		position = Vector:new {width - 100, height - 100},
		text = "Back",
		fontsize = 20,
		pressed = function() MenuManager.changeToMenu(MainMenu, MenuTransitions.Slide:setDir('right/left', 1)) end
	}

	self:add(backButton)
end

local format = string.format
function RecordsMenu:drawMenu()

	graphics.setFont(Base.getCoolFont(60))
	graphics.setColor(ColorManager.getComposedColor(8))
	graphics.print("Adventure", 125, 50)
	graphics.setColor(ColorManager.getComposedColor(2))
	graphics.print("Survival", width/2 + 125, 50)

	graphics.setFont(Base.getFont(30))
	graphics.print("Best Score:", width/2 + 50, 200)
	graphics.print("Best Time:", width/2 + 50, 300)
	graphics.print("Best Multiplier:", width/2 + 50, 400)

	graphics.setFont(Base.getCoolFont(50))
	local r = RecordsManager.records.survival
	graphics.print(format(" %.0f", r.score), width - 250, 190)
	graphics.print(format(" %.1fs", r.time), width - 250, 290)
	graphics.print(format("x%.1f", r.multiplier), width - 250, 390)

	graphics.setColor(ColorManager.getComposedColor(8))
	r = RecordsManager.records.story.bestRuns
	for i = 1, #r, 1 do
		graphics.print(format("#%d", i), 50, 25 + 120*i)
	end

	graphics.setFont(Base.getCoolFont(30))
	for i = 1, #r, 1 do
		graphics.print(format("Score: %.0f", r[i].score), 150, 20 + 120*i)
		graphics.print(r[i].level, 150, 60 + 120*i)
	end
end

RecordsMenu:addDrawablePart(RecordsMenu.drawMenu)