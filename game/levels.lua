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
		local warn = timer:new{timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1), funcToCall = pushEnemies, 
			extraelements = extraelements, onceonly = true, registerSelf = false}
		table.insert(currentLevel.timers_, warn)
		if format and format.shootattarget then
			-- follows the target with the warnings
			table.insert(currentLevel.timers_, timer:new {
				timelimit = levelEnv.time - (levelEnv.warnEnemiesTime or 1) + .01,
				prevtarget = format.target:clone(),
				registerSelf = false,
				funcToCall = function(self)
					self.timelimit = nil
					if not enemylist[1].warning then self:remove() return end
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
	local t = timer:new{timelimit = levelEnv.time, funcToCall = registerEnemies, 
		extraelements = extraelements, onceonly = true, registerSelf = false}
	table.insert(currentLevel.timers_, t)
end

function levelEnv.wait( s )
	levelEnv.time = levelEnv.time + s
end

function levelEnv.formation( data )
	local t = data.type or 'empty'
	data.type = nil
	return formations[t]:new(data)
end

function levelEnv.registerTimer( data )
	data.time = -levelEnv.time
	data.registerSelf = false
	table.insert(currentLevel.timers_, timer:new(data))
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
	currentLevel = name and levels[name] or currentLevel
	currentLevel.reload()
	local changetitle = currentLevel.title and currentLevel.title ~= "" and currentLevel.title ~= prevtitle
	local delay = changetitle and -5 or 0
	for _, t in ipairs(currentLevel.timers_) do
		t:register()
		t:start(t.time + delay)
	end
	if changetitle then
		local t = text:new {
			text = currentLevel.title,
			alphafollows = vartimer:new{ var = 255 },
			font = getCoolFont(100),
			position = vector:new{50, 200},
			limit = width - 100,
			align = 'center',
			printmethod = graphics.printf,
			variance = 0
		}
		t:register()
		timer:new{
			timelimit = 3,
			running = true,
			funcToCall = function ( timer )
				if timer.first then t.delete = false timer:remove() return end
				timer.first = true
				t.alphafollows:setAndGo(255, 0, 100)
			end
		}
	end 
end

function closeLevel()
	for _, t in ipairs(currentLevel.timers_) do
		t:stop()
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
	cleartable(levels)
	local files = filesystem.enumerate('levels')
	for _, file in ipairs(files) do
		local lev = assert(filesystem.load('levels/' .. file))
		currentLevel = {}
		currentLevel.reload = loadLevel(lev)
		levels[file:sub(0, file:len() - 4)] = currentLevel
		currentLevel.run = nil
	end
	currentLevel = nil

	local ls = {}
	local levelselectalpha = vartimer:new{ speed = 300 }
	local pos = vector:new {-100, 120}
	for name, level in pairs(levels) do
		pos:add(250)
		if pos.x + 100 >= width then
			pos.x = 150
			pos.y = pos.y + 238
		end
		table.insert(ls, button:new{
			size = 100,
			levelname = name,
			position = pos:clone(),
			text = name,
			fontsize = 20,
			menu = levelselect,
			alphafollows = levelselectalpha,
			pressed = function(self)
				self.alphafollows:setAndGo(255, 0)
				self.visible = false
				neweffects(self, 40)
				reloadStory(self.levelname)
			end
		})
	end

	table.insert(ls, button:new{
		size = 50,
		position = pos:set(920, 580),
		text = "back",
		fontsize = 20,
		menu = levelselect,
		alphafollows = levelselectalpha,
		pressed = function(self)
			for _, but in pairs(UI.paintables.levelselect) do
				but:close()
			end
			self.visible = false
			neweffects(self, 26)
			self.alphafollows:setAndGo(255, 0)
			UI.restartMenu()
		end
	})
	UI.paintables.levelselect = ls
end