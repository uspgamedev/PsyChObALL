module('levels', package.seeall)

levels = {

}
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
		local enemy = enemies[name]
		for i = 1, n do
			enemylist[i] = enemy:new(base.clone(cp))
		end
	else
		local k, s = 1, #name
		for i = 1, n do
			enemylist[i] = enemies[name[k]]:new(base.clone(cp))
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
	return formations[t]:new(data)
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
			alphafollows = VarTimer:new{ var = 254 },
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
				t.alphafollows:setAndGo(254, 1, 100)
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
	base.clearTable(levels)
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

function reloadPractice()
	local ls = {}
	local levelselectalpha = VarTimer:new{ speed = 300, pausable = false }
	local translate = VarTimer:new{ var = 0, speed = width*2, pausable = false }

	local b = {}
	b[1] = Button:new {size = 100, position = Vector:new{156, height/2 - 100}, fontsize = 20,
		menu = levelselect, pressed = function(self)
				levelselectalpha:setAndGo(255, 0)
				self.visible = falsen
				neweffects(self, 40)
				reloadStory(self.levelname)
			end,
		draw = function(self)
			if not self.visible or levelselectalpha.var == 0 then return end
			graphics.translate(-translate.var, 0)
			Button.draw(self)
			if self.hoverring and self.hoverring.size > 2 then
				graphics.setPixelEffect(base.circleShader)
				CircleEffect.draw(self.hoverring) 
				graphics.setPixelEffect()
			end
			graphics.translate(translate.var, 0)
		end,
		isClicked = function ( self, x, y )
			return Button.isClicked(self, x + translate.var, y )
		end,
		update = function(self, dt)
			if self.hoverring.size > self.size then
				self.hoverring.size = self.size
				self.hoverring.sizeGrowth = 0
			end
			if self.menu ~= state then
				if self.onHover then 
					self.onHover = false
					self:hover(false)
				end
				return
			end
			if self.onHover ~= ((mouseX + translate.var - self.x)^2 + (mouseY - self.y)^2 < self.size^2) then
				self.onHover = not self.onHover
				self:hover(self.onHover)
			end
		end} 
	b[2] = b[1]:clone()
	b[2].position:set(412, nil)
	b[3] = b[1]:clone()
	b[3].position:set(668, nil)
	b[4] = b[1]:clone()
	b[4].position:set(924, nil)

	local back = Button:new{
		size = 50,
		position = Vector:new{width - 160, 580},
		text = "back",
		fontsize = 20,
		menu = levelselect,
		alphafollows = levelselectalpha,
		draw = function(self)
			Button.draw(self)
			graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alphafollows.var, self.coloreffect))
			graphics.setFont(getCoolFont(70))
			graphics.printf("Practice", 0, 30, width, 'center')
		end,
		pressed = function(self)
			for _, but in pairs(UI.paintables.levelselect) do
				but:close()
			end
			self.visible = false
			neweffects(self, 26)
			self.alphafollows:setAndGo(254, 1, 300)
			UI.restartMenu()
		end
	}
	table.insert(ls, back)

	local nextB = Button:new{
		size = 50,
		position = Vector:new{width/2 + 100, 400},
		text = ">",
		fontsize = 55,
		draw = b[1].draw,
		isClicked = b[1].isClicked,
		update = b[1].update,
		menu = levelselect,
		pressed = function(self)
			translate:setAndGo(nil, translate.var + width)
		end
	}
	local prevB = Button:new{
		size = 50,
		position = Vector:new{width/2 - 100, 400},
		text = "<",
		fontsize = 55,
		draw = b[1].draw,
		isClicked = b[1].isClicked,
		update = b[1].update,
		menu = levelselect,
		pressed = function(self)
			translate:setAndGo(nil, translate.var - width)
		end
	}
	local fixeff  = function(self)
		self.effectsBurst.funcToCall = function()
			self.x = self.x - translate.var
			neweffects(self, 2)
			self.x = self.x + translate.var
		end
	end

	local transl = Vector:new{0, 0}
	local levelN = 5
	for i = 1, levelN do
		if 'Level ' .. i > lastLevel then break end
		for j = 1, 4 do
			if j ~= 4 or i ~= 1 then
				local levelname = 'Level ' .. i .. '-' .. j
				if lastLevel < levelname then break end
				local but = b[j]:clone()
				but.levelname = levelname
				but.position:add(transl)
				but:setText(but.levelname)
				but.alphafollows = levelselectalpha
				fixeff(but)
				table.insert(ls, but)
			end
		end
		if i > 1 then
			but = prevB:clone()
			but.position:add(transl)
			but:setText()
			but.alphafollows = levelselectalpha
			fixeff(but)
			table.insert(ls, but)
		end
		if i < levelN and 'Level ' .. (i+1) <= lastLevel then
			but = nextB:clone()
			but.position:add(transl)
			but:setText()
			but.alphafollows = levelselectalpha
			fixeff(but)
			table.insert(ls, but)
		end

		transl:add(width, 0)
	end

	local m = {noShader = true}
	m.__index = m
	setmetatable(ls, m)
	UI.paintables.levelselect = ls
end