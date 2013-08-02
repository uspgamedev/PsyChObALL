module('levels', package.seeall)

levels = {

}
currentLevel = nil

function pushEnemies( timer, enemies )
	for _, enemy in ipairs(enemies) do
		enemy:getWarning()
	end
	timer.running = false
end

function registerEnemies( timer, enemies, ... )
	for _, enemy in ipairs(enemies) do
		enemy:register(...)
	end
	timer.running = false
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
		local warn = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), funcToCall = pushEnemies, extraelements = extraelements, persistent = true}
		table.insert(currentLevel.timers_, warn)
		if format and format.shootattarget then
			-- follows the target with the warnings
			table.insert(currentLevel.timers_, timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
				prevtarget = format.target:clone(),
				persistent = true,
				funcToCall = function(self)
					self.timelimit = nil
					if not enemylist[1].warning then self.running = false self.timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1) return end
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
	local t = timer:new{timelimit = levelEnv.time, funcToCall = registerEnemies, extraelements = extraelements, persistent = true}
	table.insert(currentLevel.timers_, t)
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

function runLevel( name )
	currentLevel = name and levels[name] or currentLevel
	currentLevel.reload()
	for _, t in ipairs(currentLevel.timers_) do
		t:start()
	end
end

function loadLevel( lev )
	return function ()
		currentLevel = { reload = currentLevel.reload }
		setfenv(lev, currentLevel)
		lev()
		currentLevel.timers_ = {}
		levelEnv.time = 0
		setfenv(currentLevel.run, levelEnv)
		currentLevel.run()
	end
end

function loadAll()
	cleartable(levels)
	local files = filesystem.enumerate('levels')
	for _, file in ipairs(files) do
		local lev = assert(filesystem.load('levels/' .. file))
		currentLevel = {}
		currentLevel.reload = loadLevel(lev)
		currentLevel.reload()
		levels[currentLevel.name] = currentLevel
	end
	currentLevel = nil
end