module('UI', Base.globalize)

function init()
	resetpass = Cheats.password 'reset'

	restartMenu()
end

function restartMenu()
	resetVars()
	Timer.closeOldTimers()
	MenuManager.changeToMenu(MenuManager.MainMenu, MenuTransitions.Fade)
	if SoundManager.currentsong ~= SoundManager.menusong then
		SoundManager.changeSong(SoundManager.menusong)
	end
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
			if Levels.currentLevel.wasSelected then
				reloadStory(Levels.currentLevel.name_, true)
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
		if paintables.deathEffects then
			for _, e in pairs(paintables.deathEffects.bodies) do e:handleDelete() end
			paintables.deathEffects = nil
		end

		if state == story then
			Levels.closeLevel()
		end
		psycho.pseudoDied = false
		psycho.canBeHit = true
		psycho.alpha = 255

		paused = false
		restartMenu()

		Cheats.devmode = false
		Cheats.image.enabled = false
		resetted = false

		SoundManager.reset()
		timefactor = 1.0
		ColorManager.currentEffect = nil
	end

	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then FileManager.resetStats() end
	end
end

function draw()
	graphics.setPixelEffect()
	--[[Drawing On-Game Info]]
	if onGame() then
		graphics.setColor(ColorManager.getComposedColor())
		if state == survival then
			graphics.setFont(Base.getCoolFont(22))
			graphics.print(string.format("%.0f", score), 68, 20)
			graphics.print(string.format("%.1fs", gametime), 68, 42)
			graphics.setFont(Base.getFont(12))
			graphics.print("Time:", 25, 48)
			graphics.print("Score:", 25, 24)
			graphics.print(string.format("Best Score: %0.f", math.max(records.survival.score, score)),     25, 68)
			graphics.print(string.format("Best Time: %.1fs", math.max(records.survival.time,  gametime)), 25, 85)
			graphics.print(string.format("Best Mult: x%.1f", math.max(records.survival.multiplier,  multiplier)), width - 115, 83)
			graphics.setFont(Base.getFont(14))
			graphics.print("ulTrAbLaST:", 25, 105)
			graphics.setFont(Base.getCoolFont(20))
			graphics.print(string.format("%d", ultracounter), 110, 100)
			graphics.setFont(Base.getFont(20))
			graphics.print("___________", 25, 106)
			graphics.setFont(Base.getCoolFont(40))
			graphics.print(string.format("x%.1f", multiplier), width - 130, 35)
		elseif state == story then
			graphics.setFont(Base.getCoolFont(30))
			graphics.print(string.format("%.0f", score), 25, 48)
			graphics.print(string.format("%.0f", psycho.lives), 25, 98)
			graphics.setFont(Base.getCoolFont(20))
			graphics.print(Levels.currentLevel.chapter, 200, 40)
			graphics.setFont(Base.getCoolFont(18))
			graphics.print("Score:", 25, 30)
			graphics.print("Lives:", 25, 80)
			graphics.print("ulTrAbLaST:", 25, 130)
			graphics.setFont(Base.getCoolFont(30))
			graphics.print(string.format("%d", ultracounter), 140, 125)
			graphics.setFont(Base.getFont(24))
			graphics.print("___________", 25, 136)
		end
		
		graphics.setFont(Base.getFont(12))
		if Cheats.devmode then graphics.print("dev mode on!", 446, 5) end
		if Cheats.invisible then graphics.print("Invisible mode on!", 432, 18) end
		if Cheats.image.enabled then
			if 	 Cheats.image.pass == 'yan' then graphics.print("David Robert Jones mode on!", 395, 32)
			elseif Cheats.image.pass == 'pizza' then graphics.print("Italian mode on!", 438, 32) 
			elseif Cheats.image.pass == 'rica' then graphics.print("Richard mode on!", 433, 32)
			elseif Cheats.image.pass == 'rika' then graphics.print("Detective mode on!", 428, 32) end
		end
		if Cheats.dkmode then graphics.print("DK mode on!", 448, 45) end
		graphics.setFont(Base.getCoolFont(40))
		if Cheats.tiltmode then graphics.print("*TILT*", 446, 80, -angle.var) end
		graphics.setFont(Base.getFont(12))
	end
	--[[Drawing Things that how up on every page]]
	--[[End of Drawing On-Game Info]]

	local color = ColorManager.getComposedColor()
	graphics.setColor(color)
	graphics.setFont(Base.Base.getFont(12))
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
	
	--[[Drawing Pause Menu]]
	if paused and onGame() then
		graphics.setColor(ColorManager.getComposedColor(- ColorManager.colorCycleTime / 2))
		graphics.setFont(Base.getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(Base.getCoolFont(23))
		if state == survival then graphics.print("Press R to retry", 280, 640)
		else graphics.print("Press R to start over", 280, 640) end
		graphics.setFont(Base.getFont(30))
		if state == survival then graphics.print("_____________", 280, 645)
		else 	graphics.print("__________________", 280, 645) end
		graphics.setFont(Base.getCoolFont(18))
		graphics.print("Press B", 580, 650)
		graphics.print(pauseText(), 649, 650)
		graphics.setFont(Base.getFont(12))
	end
	--[[End of Drawing Pause Menu]]

	if state == levelselect then

	end
end