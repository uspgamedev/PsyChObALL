module('UI', base.globalize)

function init()
	playbutton = button:new{
		size = 120,
		position = vector:new {width/2 + 200, 430},
		text = 'Survival',
		alphafollows = alphatimer,
		fontsize = 40
	}

	function playbutton:pressed()
		closeMenu()
		alphatimer:setAndGo(255, 0)
		reloadSurvival()
		self.visible = false
		neweffects(self, 100)
		button.cancelclick = true
	end


	storybutton = button:new {
		size = 120,
		position = vector:new {width/2 - 200, 430},
		text = 'Adventure',
		alphafollows = alphatimer,
		fontsize = 40
	}

	function storybutton:pressed()
		closeMenu()
		alphatimer:setAndGo(255, 0)
		--selectLevel()
		reloadStory 'Level 1-1'
		self.visible = false
		neweffects(self, 50)
		button.cancelclick = true
	end


	local controlsbutton = button:new {
		size = 80,
		position = vector:new {width - 100, height - 100},
		text = "Controls",
		fontsize = 20,
		alphafollows = alphatimer,
		pressed = toTutorialMenu
	}
	local backbutton = button:new {
		size = 80,
		position = vector:new {100, height - 100},
		text = "Back",
		menu = tutorialmenu,
		fontsize = 20,
		alphafollows = alphatimer,
		pressed = toMainMenu
	}

	local testingbutton = button:new {
		size = 50,
		position = vector:new{width/2, height - 100},
		text = "Practice",
		fontsize = 15,
		alphafollows = alphatimer,
		pressed = selectLevel
	}

	paintables.menu = {playbutton, testingbutton, storybutton, controlsbutton, backbutton}

	resetpass = cheats.password 'reset'

	restartMenu()
end

function selectLevel()
	state = levelselect
	closeMenu()
	alphatimer:setAndGo(255, 0)
	UI.paintables.levelselect[1].alphafollows:setAndGo(0, 255)
	for _, but in pairs(UI.paintables.levelselect) do
		but:start()
	end

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
	alphatimer:setAndGo(0, 255)
	state = mainmenu
	resetVars()
	timer.closenonessential()
	soundmanager.changeSong(soundmanager.menusong)
	for _, b in pairs(paintables.menu) do b:start() end
end

function mousepressed( x, y, btn )
	button.mousepressed(x,y,button)
	if not swypetimer.running then
		if btn == 'r' and state == mainmenu then
			toTutorialMenu()
		end
	end
end

function mousereleased( x, y, btn )
	button.mousereleased(x, y, btn)
end

function keypressed( key )
	if key == 'r' and paused then
		reloadStory 'Level 1-1'
	end

	if key == 'restartstory' or (gamelost and key == 'r') then
		--restarting
		if gamelostinfo.isrestarting then return end
		gamelostinfo.isrestarting = true
		gamelostinfo.timeofrestart = totaltime
		local m = (totaltime - gamelostinfo.timeofdeath - .07)/gamelostinfo.timetorestart
		for _, eff in pairs(global.paintables.psychoeffects) do
			eff.speed:negate():mult(m, m)
		end
		global.paintables.psychoeffects[1].prevdist = 
			global.paintables.psychoeffects[1].position:distsqr(global.paintables.psychoeffects[1].firstpos)
		timer:new{
			running = true,
			timeaffected = false,
			onceonly = true,
			timelimit = gamelostinfo.timetorestart,
			funcToCall = function()
				if not global.paintables.psychoeffects then return end
				local s = math.sqrt(global.paintables.psychoeffects[1].prevdist)/.025
				s = s / global.paintables.psychoeffects[1].speed:length()
				for _, eff in pairs(global.paintables.psychoeffects) do
					eff.speed:mult(s, s)
				end
			end
		}
	end

	if (gamelost or paused) and key == 'b' then
		global.paintables.psychoeffects = nil
		if state == story then
			levels.closeLevel()
			lives = 3
		end
		psycho.pseudoDied = false
		psycho.canbehit = true

		paused = false
		restartMenu()

		cheats.devmode = false
		cheats.image.enabled = false
		resetted = false

		soundmanager.reset()
		timefactor = 1.0
		currentEffect = nil
	end

	if state == mainmenu then
		resetted = resetpass (key)
		if resetted then filemanager.resetstats() end
	end

	if state == mainmenu and key == 'q' then
		toAchievMenu()
	elseif state == achievmenu and key == 'q' then
		toMainMenu()
	end
end

function update(dt)
	for _,v in pairs(paintables) do
		for __,b in pairs(v) do
			b:update(dt)
		end
	end
end

function draw()
	--[[Drawing On-Game Info]]
	if onGame() then
		graphics.setColor(color(colortimer.time))
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
			graphics.print(string.format("%.0f", lives), 25, 98)
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
			graphics.setFont(getCoolFont(40))
			graphics.print(string.format("x%.1f", multiplier), 950, 35)
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
	--[[End of Drawing On-Game Info]]

	--[[Drawing Things that show up on every page]]
	graphics.setColor(color(colortimer.time))
	graphics.print(string.format("FPS:%.0f", love.timer.getFPS()), width - 80, 10)
	maincolor[4] = 70 --alpha
	graphics.setColor(maincolor)
	soundmanager.drawSoundIcon(width - 50, height - 50)
	--[[End of Drawing Things that show up on every page]]

	--[[Drawing Death Screen]]
	if gamelost and onGame() then
		graphics.setColor(color(colortimer.time - colortimer.timelimit / 2))
		if state == survival then
			if cheats.wasdev then
				graphics.setFont(getCoolFont(20))
				graphics.print("Your scores didn't count, cheater!", 382, 215)
			else
				if besttime == gametime then
					graphics.setFont(getFont(35))
					graphics.print("You beat the best time!", 260, 100)
				end	
				if bestscore == score then
					graphics.setFont(getFont(35))
					graphics.print("You beat the best score!", 290, 140)
				end
				if bestmult == multiplier then
					graphics.setFont(getFont(35))
					graphics.print("You beat the best multiplier!", 320, 180)
				end
			end
		end
		graphics.setFont(getCoolFont(40))
		graphics.print(deathText(), 270, 300)
		if state == survival then graphics.print(string.format("You lasted %.1fsecs", gametime), 486, 450) end
		graphics.setFont(getCoolFont(23))
		graphics.print("Press R to retry", 300, 640)
		graphics.setFont(getFont(30))
		graphics.print("_____________", 300, 645)
		graphics.setFont(getCoolFont(18))
		graphics.print("Press B", 580, 650)
		graphics.print(pauseText(), 649, 650)
	end
	--[[End of Drawing Death Screen]]
	maincolor[4] = 255

	--drawing menu paintables
	for _,v in pairs(paintables) do
		for k, p in pairs(v) do
			p:draw()
		end
	end

	--[[Drawing Menu]]
	if alphatimer.var > 0 then
		graphics.setColor(color(colortimer.time - colortimer.timelimit / 2))
		graphics.push()
		
		--drawing mainmenu
		graphics.setFont(getFont(12))
		graphics.setColor(color(colortimer.time * 0.856, alphatimer.var))
		graphics.print("v" .. version, width/2 - 10, 690)
		graphics.print('Write "reset" to delete stats', 15, 10)
		if resetted then graphics.print("~~stats deleted~~", 25, 23) end

		if latest ~= version then
			graphics.print("Version " .. latest, 422, 700)
			graphics.print("is available to download!", 510, 700)
		end
		graphics.print("A game by Marvellous Soft/USPGameDev", 14, 696)

		graphics.setFont(getCoolFont(24))
		if cheats.konamicode then
			graphics.print("KONAMI CODE!", 450, 5)
		end
		graphics.setFont(getFont(30))

		graphics.setColor(color(colortimer.time * 4.5 + .54, alphatimer.var))
		graphics.draw(logo, (width - logo:getWidth()/4)/2, 75, nil, 0.25, 0.20)
		graphics.setFont(getFont(12))
		--end of mainmenu

		graphics.translate(width, 0)
		--drawing tutorialmenu
		graphics.setColor(color(colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("CONTROLS", 380, 36)
		graphics.setFont(getCoolFont(40))
		graphics.print("Survival Mode:", 170, 350)
		graphics.setColor(color(colortimer.time * 2.5 + .54))
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
		graphics.setColor(color(colortimer.time * 0.856))
		graphics.print("ulTrAbLaST", 290, 242)
		graphics.setColor(color(colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 10)
		graphics.circle("fill", 520, 450, 10)
		graphics.circle("fill", 160, 510, 10)
		graphics.circle("fill", 520, 240, 10)
		graphics.circle("fill", 520, 280, 10)
		graphics.setColor(color(colortimer.time * 7.5 + .54))
		graphics.circle("fill", 520, 180, 10)
		graphics.circle("fill", 130, 450, 10)
		graphics.circle("fill", 50, 263, 10)
		--end of tutorialmenu

		graphics.translate(-2 * width, 0)
		--drawing achievmentsmenu
		graphics.setColor(color(colortimer.time * 1.5 + .54))
		graphics.setFont(getCoolFont(50))
		graphics.print("ACHIEVEMENTS", 340, 36)
		graphics.setColor(color(colortimer.time * 6.5 + .54))
		graphics.circle("fill", 130, 180, 5)
		graphics.setColor(color(colortimer.time * 7.5 + .54))
		graphics.circle("fill", 130, 210, 5)
		graphics.setFont(getCoolFont(30))
		graphics.print("YOU SHOULDNT BE HERE", 340, 306)
		--end of achievmentsmenu

		graphics.pop()
	end
	--[[End of Drawing Menu]]
	
	--[[Drawing Pause Menu]]
	if paused and onGame() then
		graphics.setColor(color(colortimer.time - colortimer.timelimit / 2))
		graphics.setFont(getFont(40))
		graphics.print("Paused", 270, 300)
		graphics.setFont(getCoolFont(23))
		graphics.print("Press R to start over", 280, 640)
		graphics.setFont(getFont(30))
		graphics.print("__________________", 280, 645)
		graphics.setFont(getCoolFont(18))
		graphics.print("Press B", 580, 650)
		graphics.print(pauseText(), 649, 650)
		graphics.setFont(getFont(12))
	end
	--[[End of Drawing Pause Menu]]

	if state == levelselect then

	end
end