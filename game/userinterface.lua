module('UI', base.globalize)

function init()
	playbutton = Button:new{
		size = 120,
		position = Vector:new {width/2 + 200, 430},
		text = 'Survival',
		alphafollows = alphatimer,
		fontsize = 40
	}

	function playbutton:pressed()
		closeMenu()
		alphatimer:setAndGo(254, 1)
		reloadSurvival()
		self.visible = false
		neweffects(self, 50)
		Button.cancelclick = true
	end


	storybutton = Button:new {
		size = 120,
		position = Vector:new {width/2 - 200, 430},
		text = 'Adventure',
		alphafollows = alphatimer,
		fontsize = 40
	}

	function storybutton:pressed()
		closeMenu()
		alphatimer:setAndGo(254, 1)
		reloadStory 'Level 1-1'
		self.visible = false
		neweffects(self, 50)
		Button.cancelclick = true
	end


	local controlsbutton = Button:new {
		size = 80,
		position = Vector:new {width - 100, height - 100},
		text = "Controls",
		fontsize = 20,
		alphafollows = alphatimer,
		pressed = toTutorialMenu
	}

	local backbutton = Button:new {
		size = 80,
		position = Vector:new {100, height - 100},
		text = "Back",
		menu = tutorialmenu,
		fontsize = 20,
		alphafollows = alphatimer,
		pressed = toMainMenu
	}

	local testingbutton = Button:new {
		size = 50,
		position = Vector:new{width/2, height - 100},
		text = "Practice",
		fontsize = 15,
		alphafollows = alphatimer,
		pressed = selectLevel
	}

	paintables.menu = {playbutton, testingbutton, storybutton, controlsbutton, backbutton}
	local m = {
		updateComponents = Body.updateComponents,
		drawComponents = Body.drawComponents,
		bodies = paintables.menu
	}
	m.__index = m
	setmetatable(paintables.menu, m)

	resetpass = cheats.password 'reset'

	restartMenu()
end

function selectLevel()
	state = levelselect
	closeMenu()
	alphatimer:setAndGo(254, 1)
	paintables.levelselect[1].alphafollows:setAndGo(1, 254)
	for _, but in pairs(paintables.levelselect) do
		but:start()
	end
	global.levelselected = true

	mouse.setGrab(false)
end

function toTutorialMenu()
	swypetimer:setAndGo(nil, width)
	state = tutorialmenu
end

function toMainMenu()
	swypetimer:setAndGo(nil, 0)
	state = mainmenu
end

function toAchievMenu()
	swypetimer:setAndGo(nil, -width)
	state = achievmenu
end

function closeMenu()
	for _, b in pairs(paintables.menu) do
		b:close()
	end
end

function restartMenu()
	global.levelselected = false
	alphatimer:setAndGo(1, 254)
	state = mainmenu
	resetVars()
	Timer.closenonessential()
	if SoundManager.currentsong ~= SoundManager.menusong then
		SoundManager.changeSong(SoundManager.menusong)
	end
	for _, b in pairs(paintables.menu) do b:start() end
end

local pauseTexts = {"to surrender","to go back","to give up","to admit defeat","to /ff", "to RAGE QUIT","if you can't handle the balls"}
local pauseMessage

function pauseText()
	pauseMessage = pauseMessage or pauseTexts[math.random(#pauseTexts)]
	return pauseMessage
end

function resetPauseText()
	pauseMessage = nil
end

function mousepressed( x, y, btn )
	Button.mousepressed(x, y, btn)
	if not swypetimer.running then
		if btn == 'r' and state == mainmenu then
			toTutorialMenu()
		end
	end
end

function mousereleased( x, y, btn )
	Button.mousereleased(x, y, btn)
end

function keypressed( key )
	if (key == 'escape' or key == 'p') and onGame() and not DeathManager.gameLost then
		resetPauseText()
		paused = not paused --pauses or unpauses
		mouse.setGrab(not paused) --releases the mouse if paused
	end

	if key == 'r' and paused then
		if state == story then
			if levelselected then
				local n = levels.currentLevelname
				resetVars()
				reloadStory(n)
			else
				reloadStory 'Level 1-1'
			end
		elseif state == survival then
			reloadSurvival()
		end
	end

	if DeathManager.gameLost and key == 'r' then
		DeathManager.beginGameRestart()
	end

	if (DeathManager.gameLost or paused) and key == 'b' then
		if paintables.psychoeffects then
			for _, e in pairs(paintables.psychoeffects) do e:handleDelete() end
			paintables.psychoeffects = nil
		end

		if state == story then
			levels.closeLevel()
		end
		psycho.pseudoDied = false
		psycho.canbehit = true

		paused = false
		restartMenu()

		cheats.devmode = false
		cheats.image.enabled = false
		resetted = false

		SoundManager.reset()
		timefactor = 1.0
		ColorManager.currentEffect = nil
	end

	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then FileManager.resetStats() end
	end

	if state == mainmenu and key == 'q' then
		toAchievMenu()
	elseif state == achievmenu and key == 'q' then
		toMainMenu()
	end
end

function draw()
	graphics.setPixelEffect()
	--[[Drawing On-Game Info]]
	if onGame() then
		graphics.setColor(ColorManager.getComposedColor())
		if state == survival then
			graphics.setFont(getCoolFont(22))
			graphics.print(string.format("%.0f", score), 68, 20)
			graphics.print(string.format("%.1fs", gametime), 68, 42)
			graphics.setFont(getFont(12))
			graphics.print("Time:", 25, 48)
			graphics.print("Score:", 25, 24)
			graphics.print(string.format("Best Score: %0.f", math.max(bestscore, score)),     25, 68)
			graphics.print(string.format("Best Time: %.1fs", math.max(besttime,  gametime)), 25, 85)
			graphics.print(string.format("Best Mult: x%.1f", math.max(bestmult,  multiplier)), width - 115, 83)
			graphics.setFont(getFont(14))
			graphics.print("ulTrAbLaST:", 25, 105)
			graphics.setFont(getCoolFont(20))
			graphics.print(string.format("%d", ultracounter), 110, 100)
			graphics.setFont(getFont(20))
			graphics.print("___________", 25, 106)
			graphics.setFont(getCoolFont(40))
			graphics.print(string.format("x%.1f", multiplier), width - 130, 35)
		elseif state == story then
			graphics.setFont(getCoolFont(30))
			graphics.print(string.format("%.0f", score), 25, 48)
			graphics.print(string.format("%.0f", psycho.lives), 25, 98)
			graphics.setFont(getCoolFont(20))
			graphics.print(levels.currentLevel.chapter, 200, 40)
			graphics.setFont(getCoolFont(18))
			graphics.print("Score:", 25, 30)
			graphics.print("Lives:", 25, 80)
			graphics.print("ulTrAbLaST:", 25, 130)
			graphics.setFont(getCoolFont(30))
			graphics.print(string.format("%d", ultracounter), 140, 125)
			graphics.setFont(getFont(24))
			graphics.print("___________", 25, 136)
		end
		
		graphics.setFont(getFont(12))
		if cheats.devmode then graphics.print("dev mode on!", 446, 5) end
		if cheats.invisible then graphics.print("Invisible mode on!", 432, 18) end
		if cheats.image.enabled then
			if 	 cheats.image.pass == 'yan' then graphics.print("David Robert Jones mode on!", 395, 32)
			elseif cheats.image.pass == 'pizza' then graphics.print("Italian mode on!", 438, 32) 
			elseif cheats.image.pass == 'rica' then graphics.print("Richard mode on!", 433, 32)
			elseif cheats.image.pass == 'rika' then graphics.print("Detective mode on!", 428, 32) end
		end
		if cheats.dkmode then graphics.print("DK mode on!", 448, 45) end
		graphics.setFont(getCoolFont(40))
		if cheats.tiltmode then graphics.print("*TILT*", 446, 80, -angle.var) end
		graphics.setFont(getFont(12))
	end
	--[[Drawing Things that how up on every page]]
	--[[End of Drawing On-Game Info]]

	local color = ColorManager.getComposedColor()
	graphics.setColor(color)
	graphics.setFont(base.getFont(12))
	graphics.print(string.format("FPS:%.0f", love.timer.getFPS()), width - 80, 10)
	color[4] = 70 --alpha
	graphics.setColor(color)
	SoundManager.drawSoundIcon(width - 50, height - 50)
	--[[End of Drawing Things that show up on every page]]

	--[[Drawing Death Screen]]
	if DeathManager.gameLost and onGame() then
		DeathManager.drawDeathScreen()
	end
	--[[End of Drawing Death Screen]]
	color[4] = 255


	--[[Drawing Menu]]
	if alphatimer.var > 1 then
		graphics.setColor(ColorManager.getComposedColor(- ColorManager.colorCycleTime / 2))
		graphics.push()
		
		--drawing mainmenu
		graphics.setFont(getFont(12))
		graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time * 0.144, alphatimer.var))
		graphics.print("v" .. version, width/2 - 10, 685)
		graphics.print('Write "reset" to delete stats', 15, 10)
		if resetted then graphics.print("~~stats deleted~~", 25, 23) end

		if oldVersion then
			graphics.print("Version " .. latest, 422, 700)
			graphics.print("is available to download!", 510, 700)
		end
		graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)

		graphics.setFont(getCoolFont(24))
		if cheats.konamicode then
			graphics.print("KONAMI CODE!", 450, 5)
		end
		graphics.setFont(getFont(30))

		graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time * 2.5 + 1, alphatimer.var))
		graphics.draw(logo, (width - logo:getWidth()/4)/2, 75, nil, 0.25, 0.20)
		graphics.setFont(getFont(12))
		--end of mainmenu

		graphics.translate(width, 0)
		--drawing tutorialmenu
		graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time*.25 + 3))
		graphics.setFont(getCoolFont(50))
		graphics.print("CONTROLS", 380, 36)
		graphics.setFont(getCoolFont(40))
		graphics.print("Survival Mode:", 170, 350)
		graphics.setColor(ColorManager.getComposedColor(1))
		graphics.setFont(getCoolFont(20))
		graphics.print("You get points when", 540, 425)
		graphics.print("  you kill an enemy", 570, 455)
		graphics.print("Survive as long as you can!", 152, 440)
		graphics.print("You get one more ulTrAbLaST for every 30 seconds you survive!", 182, 500)
		graphics.print("You have a limited amount of ulTrAbLaSTs to use", 540, 230)
		graphics.print("You get one more ulTrAbLaST for every 1000 points!", 540, 270)
		graphics.setFont(getCoolFont(20))
		graphics.print("Use WASD or arrows to move", 152, 170)
		graphics.print("Click or hold the left mouse button to shoot", 540, 170)
		graphics.print("Hold space to charge", 70, 252)
		graphics.setFont(getCoolFont(35))
		graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time * 0.144))
		graphics.print("ulTrAbLaST", 290, 242)

		graphics.setPixelEffect(base.circleShader)
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
		--end of tutorialmenu

		graphics.translate(-2 * width, 0)
		--drawing achievmentsmenu
		graphics.setColor(ColorManager.getComposedColor(-ColorManager.timer.time * .25 + 1))
		graphics.setFont(getCoolFont(50))
		graphics.print("ACHIEVEMENTS", 340, 36)

		graphics.setPixelEffect(base.circleShader)
		graphics.setColor(ColorManager.getComposedColor(1))
		graphics.circle("fill", 130, 180, 5)
		graphics.circle("fill", 130, 210, 5)
		graphics.setPixelEffect()
		graphics.setFont(getCoolFont(30))
		graphics.print("YOU SHOULDNT BE HERE", 340, 306)
		--end of achievmentsmenu

		graphics.pop()
	end
	--[[End of Drawing Menu]]
	
	--[[Drawing Pause Menu]]
	if paused and onGame() then
		graphics.setColor(ColorManager.getComposedColor(- ColorManager.colorCycleTime / 2))
		graphics.setFont(getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(getCoolFont(23))
		if state == survival then graphics.print("Press R to retry", 280, 640)
		else graphics.print("Press R to start over", 280, 640) end
		graphics.setFont(getFont(30))
		if state == survival then graphics.print("_____________", 280, 645)
		else 	graphics.print("__________________", 280, 645) end
		graphics.setFont(getCoolFont(18))
		graphics.print("Press B", 580, 650)
		graphics.print(pauseText(), 649, 650)
		graphics.setFont(getFont(12))
	end
	--[[End of Drawing Pause Menu]]

	if state == levelselect then

	end
end