module('levels', package.seeall)

require 'levels.formations'

current = {
	fullName = "VII - The Fall of Psycho"
}

function pushEnemies( timer, enemies )
	for _, enemy in ipairs(enemies) do
		enemy:getWarning()
	end
end

function registerEnemies( timer, enemies, ... )
	for _, enemy in ipairs(enemies) do
		enemy:register(...)
	end
end


local levelEnv = {}
local enemycreator, enemycreatorwarning = {}, {}

function levelEnv.enemy( name, n, formation, ... )
	name = name or 'simpleball'
	n = n or 1
	local enemy = enemies[name]
	local enemylist = {}
	for i=1, n do
		enemylist[i] = enemy:new{}
	end
	if formation then formation:applyOn(enemylist) end

	local extraelements = {enemylist, ...}

	if levelEnv.warnEnemies then
		local warn = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), onceonly = true, funcToCall = pushEnemies, extraelements = extraelements}
		if formation and formation.shootattarget then
			table.insert(current.timers, timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
				prevtarget = formation.target:clone(),
				funcToCall = function(self)
					self.timelimit = nil
					if not enemylist[1].warning then self.delete = true return end
					if self.prevtarget == formation.target then return end
					local speed = formation.speed or v
					for i = 1, n do
						enemylist[i].speed:set(formation.target):sub(enemylist[i].position):normalize():mult(speed, speed)
						enemylist[i].warning:recalc_angle()
					end
					self.prevtarget:set(target)
				end
			})
		end
		table.insert(current.timers, warn)
	end

	local t = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = registerEnemies, extraelements = extraelements}
	table.insert(current.timers, t)
end

function levelEnv.wait( s )
	levelEnv.time = levelEnv.time + s
end

function levelEnv.formation( data )
	local t = data.type
	data.type = nil
	return formations[t]:new(data)
end

setmetatable(levelEnv, {__index = _G})

function loadLevel( levelname )
	local lev = assert(filesystem.load('levels/' .. levelname .. '.lua'))
	current = {}
	setfenv(lev, current)
	lev()
	current.timers = {}
	levelEnv.time = 0
	setfenv(current.run, levelEnv)
	current.run()
end

function runLevel( l )
	l = l or current
	for _, t in ipairs(l.timers) do
		t:start()
	end
end