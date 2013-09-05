module('Levels', package.seeall)

levels = {} -- list of all levels
currentLevel = nil

function pushEnemies(timer, enemies)
	for _, enemy in ipairs(enemies) do
		enemy:getWarning()
	end
	timer.running = false
end

function registerEnemies(timer, enemies)
	for _, enemy in ipairs(enemies) do
		enemy:register()
	end
	timer.running = false
end


local levelEnv = {}
local enemycreator, enemycreatorwarning = {}, {}

function levelEnv.enemy( name, n, format, ... )
	name = name or 'simpleball'
	n = n or 1
	local initInfo = select('#', ...) > 0  and {...} or nil
	local enemylist = {}
	local cp
	if format and format.applyOn then cp = format.copy or {}
	else cp = format or {} end
	cp.side = cp.side or format and format.side
	cp.onInitInfo = initInfo

	if type(name) == 'string' then
		local enemy = Enemies[name]
		for i = 1, n do
			enemylist[i] = enemy:new(Base.clone(cp))
		end
	else
		local k, s = 1, #name
		for i = 1, n do
			enemylist[i] = Enemies[name[k]]:new(Base.clone(cp))
			k = k + 1
			if k > s then k = 1 end
		end
	end
	
	if format then
		if format.applyOn then
			format:applyOn(enemylist)
		end
	end

	local extraelements = {enemylist}

	if levelEnv.warnEnemies then
		-- warns about the enemy
		local warn = Timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), funcToCall = pushEnemies, 
			extraelements = extraelements, onceonly = true, registerSelf = false}
		table.insert(currentLevel.timers_, warn)
		if format and format.shootattarget then
			-- follows the target with the warnings
			local speed = format.speed or v
			table.insert(currentLevel.timers_, Timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1),
				prevtarget = format.target:clone(),
				registerSelf = false,
				funcToCall = function(self)
					if self.timelimit then self.timelimit = nil return end
					if not enemylist[1].warning then self:remove() return end
					if self.prevtarget == format.target then return end
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
	local t = Timer:new{timelimit = levelEnv.time, funcToCall = registerEnemies, 
		extraelements = extraelements, onceonly = true, registerSelf = false}
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
		onceonly = true
	}
end

setmetatable(levelEnv, {__index = _G})

function runLevel( name )
	local prevtitle = currentLevel and currentLevel.title
	closeLevel()
	currentLevel = name and levels[name]
	currentLevelname = name
	currentLevel.reload()
	local changetitle = currentLevel.title and currentLevel.title ~= "" and currentLevel.title ~= prevtitle
	local delay = changetitle and -5 or 0
	for _, t in ipairs(currentLevel.timers_) do
		t:register()
		t:start(t.time + delay)
	end
	if changetitle then
		local t = Text:new {
			text = currentLevel.title,
			alphaFollows = VarTimer:new{ var = 254 },
			font = getCoolFont(100),
			position = Vector:new{50, 200},
			limit = width - 100,
			align = 'center',
			printmethod = graphics.printf,
			variance = 0
		}
		t:register()
		Timer:new{
			timelimit = 3,
			running = true,
			funcToCall = function ( timer )
				if timer.first then t.delete = true timer:remove() return end
				timer.first = true
				t.alphaFollows:setAndGo(254, 1, 100)
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
	currentLevel = nil
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

local loaded = false
function loadAll()
	if loaded then return end
	loaded = true
	Base.clearTable(levels)
	local files = filesystem.enumerate('levels')
	for _, file in ipairs(files) do
		local lev = assert(filesystem.load('levels/' .. file))
		currentLevel = {}
		currentLevel.reload = loadLevel(lev)
		levels[file:sub(0, file:len() - 4)] = currentLevel
		currentLevel.run = nil
	end
	currentLevel = nil
end