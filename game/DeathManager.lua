module('DeathManager', Base.globalize)
local deathTexts, deathMessage
local handlePsychoExplosion
local deathDuration


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
		RecordsManager.manageHighScore()
		FileManager.writeStats()
		SoundManager.fadeOut()

		if getDeathText() == "Supreme." then resetDeathText() end -- makes it much rarer
		if state == story and getDeathText() == deathTexts[1] then
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

		gameLost = true
		UI.resetPauseText()
	end
	
	timefactor = .05

	psycho:handleDelete()
	handlePsychoExplosion()
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
	DeathEffect.bodies:kill()
	DeathEffect.bodies:clearAll()

	psycho.continuesUsed = psycho.continuesUsed + 1
	Levels.currentLevel.title = nil -- Forces it to show the title again
	AdventureState:runLevel(Levels.currentLevel.name_:sub(1, -2) .. '1', 1)
end

function startPsychoRevival( funcToCall )
	if isRestarting then return end
	isRestarting = true
	local m = deathDuration/(timeToRestart * timefactor)
	DeathManager.DeathEffect.bodies:forEach(function(eff) eff.speed:negate():mult(m, m) end)

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
			if Levels.currentLevel.wasSelected then
				AdventureState:runLevel(Levels.currentLevel.name_, true, true)
			else
				AdventureState:runLevel('Level 1-1', true)
			end
		else
			psycho:recreate()
		end
	elseif state == survival then
		Game.switchState(SurvivalState)
	end
	
	DeathEffect.bodies:kill()
	DeathEffect.bodies:clearAll()
end

local random, tan, asin, exp, log10, cos, sin = math.random, math.tan, math.asin, math.exp, math.log10, math.cos, math.sin
local deathFunctions = {
	function ( p1, p2, size ) return size end,
	function ( p1, p2, size ) return 1/random() end,
	function ( p1, p2, size ) return p1:dist(p2) end,
	function ( p1, p2, size ) return p1:distsqr(p2)/size end,
	function ( p1, p2, size ) return (size - p1:dist(p2))	end,
	function ( p1, p2, size ) return (size^2 - p1:distsqr(p2))/size end,
	function ( p1, p2, size ) return (size - p1:distsqr(p2))/size end,
	function ( p1, p2, size ) return random()*size end,
	function ( p1, p2, size ) return size/(random() + .3) end,
	function ( p1, p2, size ) return (size^1.6)/p1:dist(p2) end,
	function ( p1, p2, size ) return tan(p1:distsqr(p2)) end,
	function ( p1, p2, size ) return asin(p1:dist(p2) % 1)*size^.8 end,
	function ( p1, p2, size ) return exp(p1:dist(p2) - size/1.3) end,
	function ( p1, p2, size ) return log10(p1:dist(p2))*size^.7 end,
	function ( p1, p2, size ) return .095/(cos(p1:distsqr(p2)*size*3)/size) end, -- awesome death function
	function ( p1, p2, size ) return 20*cos(sin(cos(p1:dist(p2) % 1))) end -- weird one (mudando os cos e tan deixa ela mais bizarra)
}

DeathEffect = Body:new{
	size = Effect.size,
	bodies = Group:new{},
	__type = 'DeathEffect'
}
Body.makeClass(DeathEffect)

function DeathEffect.bodies:update( dt )
	if deathDuration then deathDuration = deathDuration + dt end
	Group.update(self, dt)
end

function DeathEffect.bodies:draw()
	graphics.setColor(ColorManager.getComposedColor(psycho.variance)) -- all of them have the same color
	Group.draw(self)
end

function DeathEffect:draw()
	graphics.draw(Base.pixel, self.position[1] - self.size, self.position[2] - self.size, 0, self.size*2)
end

local auxVec = Vector:new{}
function DeathEffect:update( dt )
	self.position:add(auxVec:set(self.speed):mult(dt))  
	--never be deleted
end

function handlePsychoExplosion()
	local psycho, Psychoball = psycho, Psychoball

	psycho.size = Psychoball.size + Psychoball.sizeDiff
	DeathEffect.bodies:kill()
	DeathEffect.bodies:clearAll()

	local deathFunc = deathFunctions[math.random(#deathFunctions)]
	local i, j = psycho.x - psycho.size, psycho.y - psycho.size
	-- the timer divides the job of creating the effect in many small steps, this may prevent lag
	Timer:new {
		running = true,
		funcToCall = function(timer)
			-- checks if the position is inside psycho
			for times = 1, 10 do
				if (i - psycho.x)^2 + (j - psycho.y)^2 <= psycho.size^2 then
					local e = DeathEffect:new{
						position = Vector:new{i, j}
					}
					local distr = deathFunc(e.position, psycho.position, psycho.size)
					e.speed:set(e.position):sub(psycho.position):normalize():mult(v * distr)
					e:kill()
					
					DeathEffect.bodies:add(e)
				end
				j = j + Effect.size
				if j > psycho.y + psycho.size then
					j = psycho.y - psycho.size
					i = i + Effect.size
					if i > psycho.x + psycho.size then
						-- When everything is finished
						DeathEffect.bodies:revive()
						psycho.visible = false
						deathDuration = 0
						timer:remove()
						return
					end
				end
			end
		end
	}

	psycho.size = Psychoball.size

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
"Requiescat in Pace", "Valar Morghulis", "What is dead may never die", "Mission Failed", "It's dead Jim", "Arrivederci", "FRANKIE SAYS RELAX"}

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
	RecordsManager.drawRecords()
	graphics.setFont(Base.getCoolFont(40))
	graphics.print(getDeathText(), 270, 300)
	if state == survival then graphics.print(string.format("You lasted %.1fsecs", RecordsManager.getGameTime()), 486, 450) end
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