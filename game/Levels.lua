module('Levels', package.seeall)

levels = {} -- list of all levels
currentLevel = nil
worldsNumber = 5 -- for now

local function pushEnemies( enemies )
	for _, enemy in ipairs(enemies) do
		enemy:getWarning()
	end
end

local function registerEnemies( enemies )
	for _, enemy in ipairs(enemies) do
		enemy:register()
		enemy:activate()
	end
end


local levelEnv = {}
local enemycreator, enemycreatorwarning = {}, {}

function levelEnv.enemy( name, n, format, ... )
	name = name or 'simpleball'
	n = n or 1
	local enemyList
	local copy
	if format and format.__type == 'formation' then
		copy = format.copy
	else
		copy = format
	end

	if type(name) == 'string' then
		enemyList = Enemies[name].bodies:getObjects(n)
	else
		enemyList = {}
		local k, s = 1, #name
		for i = 1, n do
			enemyList[i] = Enemies[name[k]].bodies:getFirstAvailable()
			k = k + 1
			if k > s then k = 1 end
		end
	end

	for i = 1, n do
		local e = enemyList[i]
		e:revive(...)
		e:deactivate()
		if copy then
			for k, v in pairs(copy) do
				e[k] = Base.clone(v)
			end
		end
	end
	
	if format and format.__type == 'formation' then
		format:applyOn(enemyList)
	end


	if levelEnv.warnEnemies then
		-- warns about the enemy
		local warn = Timer:new {
			timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
			funcToCall = function() pushEnemies(enemyList) end, 
			onceOnly = true,
			registerSelf = false
		}
		table.insert(currentLevel.timers_, warn)

		if format and format.shootAtTarget then
			-- follows the target with the warnings
			local speed = format.speed or v
			table.insert(currentLevel.timers_, Timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
				prevtarget = format.target:clone(),
				registerSelf = false,
				funcToCall = function(self)
					if self.timelimit then self.timelimit = nil return end
					if not enemyList[1].warning then self:remove() return end
					if self.prevtarget == format.target then return end
					for i = 1, n do
						enemyList[i].speed:set(format.target):sub(enemyList[i].position):normalize():mult(speed, speed)
						enemyList[i].warning:recalc_angle()
					end
					self.prevtarget:set(format.target)
				end
			})
		end
	end

	-- release the enemy onscreen
	local t = Timer:new {
		timelimit = levelEnv.time,
		funcToCall = function() registerEnemies(enemyList) end, 
		onceOnly = true,
		registerSelf = false
	}
	table.insert(currentLevel.timers_, t)
end

function levelEnv.wait( s )
	levelEnv.time = levelEnv.time + s
end

function levelEnv.formation( data )
	local t = data.type or 'empty'
	data.type = nil
	return Formations[t]:new(data)
end

function levelEnv.registerTimer( data )
	data.time = -levelEnv.time
	data.registerSelf = false
	table.insert(currentLevel.timers_, Timer:new(data))
end

function levelEnv.doNow( func )
	levelEnv.registerTimer {
		funcToCall = func,
		timelimit = 0,
		onceOnly = true
	}
end

function levelEnv.changeToLevel( levelName )
	levelEnv.doNow(function()
		if not Levels.currentLevel.wasSelected then
			if not DeathManager.gameLost then AdventureState:runLevel(levelName) end
		else
			local t = Text.bodies:getFirstAvailable():revive() 
			t.text = currentLevel.name_ .. " Completed. Press ESC or P and return to the menu."
			t.font = Base.getCoolFont(50)
			t.printFunction = graphics.printf
			t.position:set(width/2 - 400, height/2 + 20)
			t.limit = 800
			t.align = 'center'
			t:register()
		end
	end)
end

setmetatable(levelEnv, {__index = _G})

function runLevel( name )
	local prevTitle = currentLevel and currentLevel.title
	closeLevel()
	currentLevel = name and levels[name]
	currentLevel:reload_()

	local changetitle = currentLevel.title and currentLevel.title ~= "" and currentLevel.title ~= prevTitle
	local delay = changetitle and -4 or 0

	for _, t in ipairs(currentLevel.timers_) do
		t:register()
		t:start(t.time + delay)
	end

	if changetitle then
		local title = Text.bodies:getFirstAvailable():revive()
		title.text = currentLevel.title
		title.alphaFollows = VarTimer:new{ var = 1 }
		title.alpha = nil
		title.font = Base.getCoolFont(100)
		title.position:set(50, 200)
		title.limit = width - 100
		title.align = 'center'
		title.printFunction = graphics.printf
		title.variance = 0
		title:register()

		Timer:new{
			timelimit = .5,
			running = true,
			onceOnly = true,
			funcToCall = function ( timer )
				title.alphaFollows:setAndGo(0, 255, 255/1.75)
			end
		}

		Timer:new{
			timelimit = .5 + 1.75,
			running = true,
			onceOnly = true,
			funcToCall = function ( timer )
				title.alphaFollows:setAndGo(255, 0, 255/1.75)
				title.alphaFollows.alsoCall = function() title.alphaFollows:remove() title:kill() end
			end
		}
	end 
end

function closeLevel()
	if not currentLevel then return end
	for _, t in ipairs(currentLevel.timers_) do
		t:remove()
	end
	currentLevel.timers_ = nil
	if not currentLevel.wasSelected and currentLevel.score > RecordsManager.records.story[currentLevel.name_].score then
		RecordsManager.records.story[currentLevel.name_].score = currentLevel.score
	end
	currentLevel = nil
end

function loadLevel( levelFunc )
	return function (level)
		if level.timers_ then
			for _, t in ipairs(level.timers_) do
				t:remove()
			end
		end
		Base.setFunctionEnv(levelFunc, level)
		levelFunc()
		level.timers_ = {}
		level.score = 0
		level.wasSelected = false
		levelEnv.time = 0
		Base.setFunctionEnv(level.run, levelEnv)
		level.run()
	end
end

local loaded = false
function loadAll()
	if loaded then return end
	loaded = true
	Base.clearTable(levels)
	local files = filesystem.enumerate 'levels'
	for _, file in ipairs(files) do
		local lev = assert(filesystem.load('levels/' .. file))
		local level = {}
		level.name_ = file:sub(0, file:len() - 4)
		level.reload_ = loadLevel(lev)
		levels[level.name_] = level

		Base.setFunctionEnv(lev, level)
		lev() -- getting chapter name and stuff
		level.run = nil
	end
end