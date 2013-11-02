module('DeathManager', Base.globalize)
local deathTexts, deathMessage
local DeathEffect
local handlePsychoExplosion


function init()
	gameLost = false
	timeToRestart = 1
end

local moarLSDchance = 3

function manageDeath()
	if gameLost or godmode then return end
	local autorestart = state == story and psycho.lives > 0
	if not autorestart then
		mouse.setGrab(false)
		FileManager.writeStats()
		SoundManager.fadeout()

		if getDeathText() == "Supreme." then resetDeathText() end -- makes it much rarer
		if state == story and getDeathText() == "The LSD wears off" then
			setDeathMessage "Why are you even doing this?" -- or something else
		end

		if getDeathText() == "The LSD wears off" then
			SoundManager.setPitch(.8)
			deathTexts[1] = "MOAR LSD"
			-- raises chance of getting "MOAR LSD"
			for i = 1, moarLSDchance do table.insert(deathTexts, "MOAR LSD") end
			ColorManager.currentEffect = ColorManager.noLSDEffect
		elseif getDeathText() == "MOAR LSD" then
			SoundManager.setPitch(1)
			deathTexts[1] = "The LSD wears off"
			-- removes the extra "MOAR LSD"
			for i = 1, moarLSDchance do table.remove(deathTexts) end
			ColorManager.currentEffect = nil
		end

		gameLost   = true
		UI.resetPauseText()
	end
	
	timefactor = .05

	psycho:handleDelete()
	handlePsychoExplosion()
	timeOfDeath = totaltime
	isRestarting = false
end

function beginGameRestart()
	startPsychoRevival(restartGame)
end

function doGameContinue()
	if Levels.currentLevel.wasSelected then return end
	startPsychoRevival(realContinue)
end

function realContinue()
	DeathEffect.bodies = nil
	paintables.deathEffects = nil
	psycho.continuesUsed = psycho.continuesUsed + 1
	Levels.currentLevel.title = nil
	reloadStory(Levels.currentLevel.name_:sub(1, -2) .. '1', true)
end

function startPsychoRevival( funcToCall )
	if isRestarting then return end
	isRestarting = true
	timeOfRestart = totaltime
	-- this doesn't work for all effects, fix it
	local m = (timeOfRestart - timeOfDeath)/timeToRestart
	for _, eff in pairs(DeathEffect.bodies) do
		eff.speed:negate():mult(m, m)
	end
	Timer:new {
		timelimit = timeToRestart,
		timeAffected = false,
		onceOnly = true,
		running = true,
		funcToCall = funcToCall
	}
end

function restartGame()
	if state == story then 
		if not psycho.pseudoDied then
			Levels.closeLevel()
			reloadStory 'Level 1-1'
		else
			psycho:recreate()
		end
	elseif state == survival then
		reloadSurvival()
	end
	DeathEffect.bodies = nil
	paintables.deathEffects = nil
end

local deathFunctions = {
	function ( p1, p2, size ) return size end,
	function ( p1, p2, size ) return 1/math.random() end,
	function ( p1, p2, size ) return p1:dist(p2) end,
	function ( p1, p2, size ) return p1:distsqr(p2)/size end,
	function ( p1, p2, size ) return (size - p1:dist(p2))	end,
	function ( p1, p2, size ) return (size^2 - p1:distsqr(p2))/size end,
	function ( p1, p2, size ) return (size - p1:distsqr(p2))/size end,
	function ( p1, p2, size ) return math.random()*size end,
	function ( p1, p2, size ) return size/(math.random() + .3) end,
	function ( p1, p2, size ) return (size^1.6)/p1:dist(p2) end,
	function ( p1, p2, size ) return math.tan(p1:distsqr(p2)) end,
	function ( p1, p2, size ) return math.asin(p1:dist(p2) % 1)*size^.8 end,
	function ( p1, p2, size ) return math.exp(p1:dist(p2) - size/1.3) end,
	function ( p1, p2, size ) return math.log10(p1:dist(p2))*size^.7 end,
	function ( p1, p2, size ) return .095/(math.cos(p1:distsqr(p2)*size*3)/size) end, -- awesome death function
	function ( p1, p2, size ) return 20*math.cos(math.sin(math.cos(p1:dist(p2) % 1))) end -- weird one (mudando os cos e tan deixa ela mais bizarra)
}

DeathEffect = Body:new{
	spriteBatch = false,
	size = Effect.size,
	__type = 'DeathEffect'
}
Body.makeClass(DeathEffect)

function DeathEffect:updateComponents( dt )
	for i = #self.bodies, 1, -1 do
		self.bodies[i]:update(dt)
	end
end

function DeathEffect:drawComponents()
	for i = #self.bodies, 1, -1 do
		self.bodies[i]:draw()
	end
end

function DeathEffect:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance))
	graphics.draw(Base.pixel, self.position[1] - self.size, self.position[2] - self.size, 0, self.size*2)
	--just draws a rectangle, no spriteBatch stuff
end

local auxVec = Vector:new{}
function DeathEffect:update( dt )
	self.position:add(auxVec:set(self.speed):mult(dt))  
	--never be deleted
end

function handlePsychoExplosion()
	local psycho, Psychoball = psycho, Psychoball

	psycho.size = Psychoball.size + Psychoball.sizeDiff
	local deathEffects = {}
	local deathFunc = deathFunctions[math.random(#deathFunctions)]
	for i = psycho.x - psycho.size, psycho.x + psycho.size, Effect.size * 1.3 do
		for j = psycho.y - psycho.size, psycho.y + psycho.size, Effect.size * 1.3 do
			-- checks if the position is inside psycho
			if (i - psycho.x)^2 + (j - psycho.y)^2 <= psycho.size^2 then
				local e = DeathEffect:new{
					position = Vector:new{i, j},
					variance = psycho.variance
				}
				local distr = deathFunc(e.position, psycho.position, psycho.size)
				e.speed:set(e.position):sub(psycho.position):normalize():mult(v * distr)
				
				deathEffects[#deathEffects + 1] = e
			end
		end
	end

	psycho.size = Psychoball.size

	DeathEffect.bodies = deathEffects
	paintables.deathEffects = DeathEffect

	if state == story then
		if psycho.lives == 0 then
			--handle stuff
		else
			psycho:removeLife()
			psycho.canBeHit = false
			psycho.pseudoDied = true
			Timer:new{
				timelimit = 1,
				running = true,
				timeAffected = false,
				onceOnly = true,
				funcToCall = beginGameRestart
			}
		end
	end
end

deathTexts = {"The LSD wears off", "Game Over", "No one will\n      miss you", "You now lay\n   with the dead", "Yo momma so fat\n   you died",
"You ceased to exist", "Your mother\n   wouldn't be proud","Snake? Snake?\n   Snaaaaaaaaaake","Already?", "All your base\n     are belong to BALLS",
"You wake up and\n     realize it was all a nightmare", "MIND BLOWN", "Just one more", "USPGameDev Rulez", "A winner is not you", "Have a nice death",
"There is no cake\n   also you died", "You have died of\n      dysentery", "You failed", "Epic fail", "BAD END", "Supreme.", "Embrace your defeat",
"Balls have no mercy", "You have no balls left", "Nevermore...", "Rest in Peace", "Die in shame", "You've found your end", "KIA", "Status: Deceased",
"Requiescat in Pace", "Valar Morghulis", "What is dead may never die", "Mission Failed", "It's dead Jim", "Arrivederci", ""}

function getDeathText( n )
	deathMessage = n and deathTexts[n] or (deathMessage or deathTexts[math.random(#deathTexts)])
	return deathMessage
end

function setDeathMessage( msg )
	deathMessage = msg
end

resetDeathText = setDeathMessage

function drawDeathScreen()
	graphics.setColor(ColorManager.getComposedColor(- ColorManager.colorCycleTime / 2))
		if state == survival then
			if Cheats.usedDevMode then
				graphics.setFont(Base.getCoolFont(20))
				graphics.print("Your scores didn't count, cheater!", 382, 215)
			else
				if records.survival.time == gametime then
					graphics.setFont(Base.getFont(35))
					graphics.print("You beat the best time!", 260, 100)
				end	
				if records.survival.score == score then
					graphics.setFont(Base.getFont(35))
					graphics.print("You beat the best score!", 290, 140)
				end
				if records.survival.multiplier == multiplier then
					graphics.setFont(Base.getFont(35))
					graphics.print("You beat the best multiplier!", 320, 180)
				end
			end
		end
		graphics.setFont(Base.getCoolFont(40))
		graphics.print(getDeathText(), 270, 300)
		if state == survival then graphics.print(string.format("You lasted %.1fsecs", gametime), 486, 450) end
		graphics.setFont(Base.getCoolFont(23))
		if state == survival then graphics.print("Press R to retry", 280, 640)
		else 
			graphics.print("Press R to start over", 280, 640)
			if not Levels.currentLevel.wasSelected then
				graphics.print("Press C to use a continue\n    Continues Used: ", 630, 130)
				graphics.setFont(Base.getCoolFont(40))
				graphics.print(psycho.continuesUsed, 850, 157)
			end
		end
		graphics.setFont(Base.getFont(30))
		if state == survival then graphics.print("_____________", 280, 645)
		else 	graphics.print("__________________", 280, 645) end
		graphics.setFont(Base.getCoolFont(18))
		graphics.print("Press B", 580, 650)
		graphics.print(UI.pauseText(), 649, 650)
end