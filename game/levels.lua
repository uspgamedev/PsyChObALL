module('levels', package.seeall)

current = {
	fullName = "VIII - The Fall of Psycho"
}

function newEnemiesfor( enemyname )
	local newEnemiesfuncs = {}
	local bodies, create = paintables[enemyname], enemies['new' .. enemyname]
	return function (n)
		if not newEnemiesfuncs[n] then
			newEnemiesfuncs[n] = function(t, ...)
				for i= 1, n do
					local ene = create{}
					if ene.start then ene:start(...) end
					table.insert(bodies, ene)
				end
			end
		end
		return newEnemiesfuncs[n]
	end
end

function newEnemiesWarningfor( enemyname )
	local newEnemieswarn, newEnemiesrelease = {}, {}
	local bodies, create, list = paintables[enemyname], enemies['new' .. enemyname], enemies[enemyname .. 'list']
	return function ( n )
		if not newEnemieswarn[n] then
			newEnemieswarn[n] = function()
				for i= 1, n do
					list:push(create{})
				end
			end
		end
		if not newEnemiesrelease[n] then
			newEnemiesrelease[n] = function(t, ...)
				for i= 1, n do
					table.insert(bodies, list:pop(...))
				end
			end
		end
		return newEnemieswarn[n], newEnemiesrelease[n]
	end
end


local levelEnv = {}
local enemycreator, enemycreatorwarning = {}, {}

function levelEnv.enemy( name, n, ... )
	name = name or 'simpleball'
	n = n or 1
	if levelEnv.warnEnemies then
		if not enemycreatorwarning[name] then
			enemycreatorwarning[name] = newEnemiesWarningfor(name)
		end
		local add, release = enemycreatorwarning[name](n)
		local t = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), onceonly = true, funcToCall = add}
		local t2 = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = release, extraelements = {...}}
		table.insert(current.timers, t)
		table.insert(current.timers, t2)
	else
		if not enemycreator[name] then
			enemycreator[name] = newEnemiesfor(name)
		end
		local t = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = enemycreator[name](n, ...), extraelements = {...}}
		table.insert(current.timers, t)
	end
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