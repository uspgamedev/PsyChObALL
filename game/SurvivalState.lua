require 'GameState'

SurvivalState = GameState:new {}

local createSuperballTimers
local createEnemyTimers

function SurvivalState:create()
	GameState.create(self)

	SoundManager.changeSong(SoundManager.music['Limitless'])
	ColorManager.currentEffect = nil
	psycho:revive()

	state = survival
	resetVars()
	Timer.closeOldTimers()

	SoundManager.restart()

	createSuperballTimers()
	createEnemyTimers()

	for _, added in ipairs {Enemy, Enemies.superball, Shot, Effect, CircleEffect, DeathManager.DeathEffect, Warning} do
		self:add(added.bodies)
	end

	mouse.setGrab(true)
end

local superballAddTimer
local superballReleaseTimer

function createSuperballTimers() 
	local superballList = List:new{}

	superballAddTimer = Timer:new {
		timelimit = 30,
		works_on_gameLost = false
	}

	local possiblePositions = {Vector:new{30, 30}, Vector:new{width - 30, 30}, Vector:new{width - 30, height - 30}, Vector:new{30, height - 30}}
	function superballAddTimer:funcToCall()
		if superball.bodies:countAlive() > RecordsManager.getGameTime()/90 then self.timelimit = 2 return end
		local s = superball.bodies:getFirstAvailable()
		s.position:set(possiblePositions[math.random(4)])
		s:revive()
		s:deactivate()
		superballList:push(s)
		self.timelimit = 30
		superballReleaseTimer:start(0)
	end

	superballReleaseTimer = Timer:new {
		timelimit = 5,
		works_on_gameLost = false,
		running = false
	}

	function superballReleaseTimer:funcToCall()
		local s = superballList:pop()
		s:activate()
		s:register()
		self:stop()
	end

	superballAddTimer:start(5)
end

local enemyAddTimer
local enemyReleaseTimer

function createEnemyTimers()
	local enemyList = List:new{}

	enemyAddTimer = Timer:new {
		timelimit = 2,
		persistent = true
	}

	function enemyAddTimer:funcToCall() -- adds the enemies to a list
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		local e = Enemy.bodies:getFirstAvailable():revive(true)
		e:deactivate()
		enemyList:push(e)
	end

	enemyReleaseTimer = Timer:new {
		timelimit = 2,
		persistent = true
	}

	function enemyReleaseTimer:funcToCall() -- actually releases the enemies on screen
		self.timelimit = .8 + (self.timelimit - .8) / 1.09
		local e = enemyList:pop()
		e:activate()
		e:register()
	end

	enemyAddTimer:start(1.5)
	enemyReleaseTimer:start(.7)
end

function SurvivalState:destroy()
	GameState.destroy(self)

	superballAddTimer:remove()
	superballReleaseTimer:remove()
	superballAddTimer, superballReleaseTimer = nil, nil

	enemyAddTimer:remove()
	enemyReleaseTimer:remove()
	enemyAddTimer, enemyReleaseTimer = nil, nil
end