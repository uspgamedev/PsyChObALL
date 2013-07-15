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

function levelEnv.enemy( name, n, format, ... )
	name = name or 'simpleball'
	n = n or 1
	local enemy = enemies[name]
	local enemylist = {}
	for i=1, n do
		enemylist[i] = enemy:new{ side = format and format.side }
	end
	
	if format then
		if format.applyOn then
			format:applyOn(enemylist)
		else
			for i = 1, n do
				if format.speed then enemylist[i].speed:set(format.speed) end
				if format.position then enemylist[i].position:set(format.position) end
			end
		end
	end

	local extraelements = {enemylist, ...}

	if levelEnv.warnEnemies then
		-- warns about the enemy
		local warn = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), onceonly = true, funcToCall = pushEnemies, extraelements = extraelements}
		table.insert(current.timers, warn)
		if format and format.shootattarget then
			-- follows the target with the warnings
			table.insert(current.timers, timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
				prevtarget = format.target:clone(),
				funcToCall = function(self)
					self.timelimit = nil
					if not enemylist[1].warning then self.delete = true return end
					if self.prevtarget == format.target then return end
					local speed = format.speed or v
					for i = 1, n do
						enemylist[i].speed:set(format.target):sub(enemylist[i].position):normalize():mult(speed, speed)
						enemylist[i].warning:recalc_angle()
					end
					self.prevtarget:set(target)
				end
			})
		end
	end

	-- release the enemy onscreen
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