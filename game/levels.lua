module('levels', package.seeall)

current = {
	fullName = "VIII - The Fall of Psycho"
}

local newEnemiesfuncs = {}
function newEnemies( n)
	if not newEnemiesfuncs[n] then
		newEnemiesfuncs[n] = function()
			for i= 1, n do
				table.insert(enemy.bodies, enemy:new{})
			end
		end
	end
	return newEnemiesfuncs[n]
end

local newEnemieswarn, newEnemiesrelease = {}, {}
function newEnemiesWarning( n )
	if not newEnemieswarn[n] then
		newEnemieswarn[n] = function()
			for i= 1, n do
				enemylist:push(enemy:new{})
			end
		end
	end
	if not newEnemiesrelease[n] then
		newEnemiesrelease[n] = function()
			for i= 1, n do
				table.insert(enemy.bodies, enemylist:pop())
			end
		end
	end
	return newEnemieswarn[n], newEnemiesrelease[n]
end

local levelEnv = {}

function levelEnv.enemy( n)
	n = n or 1
	if levelEnv.warnEnemies then
		local add, release = newEnemiesWarning(n)
		local t = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), onceonly = true, funcToCall = add}
		local t2 = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = release}
		table.insert(current.timers, t)
		table.insert(current.timers, t2)
	else
		local t = timer:new{timelimit = levelEnv.time, onceonly = true, funcToCall = newEnemies(n, wanr)}
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