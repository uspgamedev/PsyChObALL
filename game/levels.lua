module('levels', package.seeall)

current = {
	fullName = "VIII - The Fall of Psycho"
}

function pushEnemies( timer, es )
	for _, e in ipairs(es) do
		e:getWarning()
	end
end

function registerEnemies( timer, es, ... )
	for _, e in ipairs(es) do
		e:register(...)
	end
end


local levelEnv = {}
local enemycreator, enemycreatorwarning = {}, {}

function levelEnv.enemy( name, n, ... )
	name = name or 'simpleball'
	n = n or 1
	local enemy = enemies[name]
	local enemylist = {}
	for i=1, n do
		enemylist[i] = enemy:new{}
	end
	local extraelements = {enemylist, ...}

	if levelEnv.warnEnemies then
		local warn = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), onceonly = true, funcToCall = pushEnemies, extraelements = extraelements}
		table.insert(current.timers, warn)
	end

	local t = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = registerEnemies, extraelements = extraelements}
	table.insert(current.timers, t)
end

function levelEnv.wait( s )
	levelEnv.time = levelEnv.time + s
end

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