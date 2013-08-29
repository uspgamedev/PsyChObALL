local psychosizediff = 9
local ultrablastmax
local ultratimer

local ultrablastcharging
local ultrablastrelease

Psychoball = CircleEffect:new {
	size	 = 23 - psychosizediff,
	sizediff = psychosizediff,
	maxsize = width,
	mode	 = 'fill',
	variance = 0,
	sizeGrowth = 0,
	alpha = 255,
	index = false,
	changesimage = true,
	canbehit = true,
	pseudoDied = false,
	spriteBatch = false,
	__type = 'Psychoball'
}

Body.makeClass(Psychoball)

function Psychoball.init()
	ultrablastmax = 42 -- maximum number of shots on ultrablast
	ultratimer = Timer:new {
		timelimit  = .02,
		persistent = true
	}

	function ultratimer:funcToCall() -- adds more shots to ultrablast
		if ultrablast < ultrablastmax then
			ultrablast = ultrablast + 1
		end
		if ultrablast == ultrablastmax - 1 then
			psycho.sizeGrowth = 0
		end
	end

	function ultratimer:handlereset()
		self:stop()
	end
end

local max, min = math.max, math.min
function Psychoball:update(dt)
	if self.pseudoDied or gamelost then return end
	gametime = gametime + dt
	blastime = blastime + dt
	if blastime >= 30 and state == survival then
		blastime = blastime - 30
		ultracounter = ultracounter + 1
	end
	if usingjoystick then
		self.speed:set(joystick.getAxis(1, 1), joystick.getAxis(1, 2)):mult(v*1.3, v*1.3)
		if not Shot.timer.running and (joystick.getAxis(1, 3) ~= 0 or joystick.getAxis(1, 4) ~= 0) then Shot.timer:start(Shot.timer.timelimit) end
		if Shot.timer.running and joystick.getAxis(1, 3) == 0 and joystick.getAxis(1, 4) == 0 then Shot.timer:stop() end
	end

	Body.update(self, dt)

	self.position:set(
		max(self.size + psychosizediff, min(width - self.size - psychosizediff, self.position[1])),
		max(self.size + psychosizediff, min(height - self.size - psychosizediff, self.position[2]))
	)

	if keyspressed[' '] and not ultratimer.running and ultracounter > 0 then
		self:startblast()
	end

	if not keyspressed[' '] and ultratimer.running then
		self:releaseblast()
	end

	if self.sizeGrowth < 0 and self.size + psychosizediff < 23 then
		self.linewidth = 6
		self.size = 23 - psychosizediff
		self.sizeGrowth = 0
	end

	CircleEffect.update(self, dt)
end

function Psychoball:startblast()
	ultracounter = ultracounter - 1
	ultrablast = 10
	self.sizeGrowth = 17
	self.linewidth = 6
	ultratimer:start()
end

function Psychoball:releaseblast()
	ultratimer:stop()
	self.sizeGrowth = -300
	do_ultrablast()
end

function Psychoball:draw()
	if self.pseudoDied or gamelost then return end
	self.size = self.size + psychosizediff
	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alphafollows and self.alphafollows.var or self.alpha, self.coloreffect))
	graphics.circle(self.mode, self.position[1], self.position[2], self.size)
	self.size = self.size - psychosizediff
end

local effects = {
	function ( p1, p2, size )
		return size
	end,
	function ( p1, p2, size )
		return 1/math.random()
	end,
	function ( p1, p2, size )
		return p1:dist(p2)
	end,
	function ( p1, p2, size )
		return p1:distsqr(p2)/size
	end,
	function ( p1, p2, size )
		return (size - p1:dist(p2))
	end,
	function ( p1, p2, size )
		return (size^2 - p1:distsqr(p2))/size
	end,
	function ( p1, p2, size )
		return (size - p1:distsqr(p2))/size
	end,
	function ( p1, p2, size )
		return math.random()*size
	end,
	function ( p1, p2, size )
		return size/(math.random() + .3)
	end,
	function ( p1, p2, size )
		return (size^1.6)/p1:dist(p2)
	end,
	function ( p1, p2, size )
		return math.tan(p1:distsqr(p2))
	end,
	function ( p1, p2, size )
		return math.asin(p1:dist(p2) % 1)*size^.8
	end,
	function ( p1, p2, size )
		return math.exp(p1:dist(p2) - size/1.3)
	end,
	function ( p1, p2, size )
		return math.log10(p1:dist(p2))*size^.7
	end
}

local auxVec = Vector:new{}
local updateHelper = function(self, dt)
	self.position:add(auxVec:set(self.speed):mult(dt))	
	--never be deleted
end
local drawHelper = function ( self )
	graphics.setColor(ColorManager.getComposedColor(ColorManager.timer.time + self.variance))
	graphics.rectangle(self.mode, self.position[1] - self.size, self.position[2] - self.size, self.size*2, self.size*2)
end
function Psychoball:handleDelete()
	Shot.timer:stop() -- stops shooting
	self.speed:set(0,0) -- stops moving
	
	self.size = Psychoball.size + psychosizediff
	local deatheffects = {}
	self.sizeGrowth = -300
	local efunc = effects[math.random(#effects)]
	for i = self.x - self.size, self.x + self.size, Effect.size * 1.3 do
		for j = self.y - self.size, self.y + self.size, Effect.size * 1.3 do
			if (i - self.x)^2 + (j - self.y)^2 <= self.size^2 then
				local e = Effect:new{
					position = Vector:new{i, j},
					variance = self.variance,
					coloreffect = self.coloreffect,
					alpha = self.alpha,
					alphafollows = self.alphafollows
				}
				local distr = efunc(e.position, self.position, self.size)
				e.speed = (e.position - self.position):normalize():mult(v * distr, v * distr)
				e.update = updateHelper
				e.draw = drawHelper
				e.spriteBatch = false
				
				table.insert(deatheffects, e)
			end
		end
	end
	deatheffects[1].firstpos = deatheffects[1].position:clone()
	deatheffects[1].update = function ( self, dt )
		updateHelper(self, dt)
		if gamelostinfo.isrestarting and not self.speed:equals(0, 0) then
			local curdist = self.position:distsqr(self.firstpos)
			if curdist < 1 or curdist > self.prevdist then
				if state == story then 
					if not psycho.pseudoDied then levels.closeLevel() reloadStory 'Level 1-1'
					else psycho:recreate() end
				elseif state == survival then reloadSurvival() end
				paintables.psychoeffects = nil
				return
			end
			self.prevdist = curdist
		end
	end
	self.size = Psychoball.size
	local m = {
		updateComponents = function ( self, dt )
			for _, body in pairs(self) do body:update(dt) end
		end,
		drawComponents = function (self)
			for _, body in pairs(self) do
				body:draw()
			end
		end
	}
	m.__index = m
	setmetatable(deatheffects, m)
	paintables.psychoeffects = deatheffects
	if state ~= story then return end
	if lives == 0 then
		--handle stuff
	else
		lives = lives - 1
		self.canbehit = false
		self.pseudoDied = true
		Timer:new{ timelimit = 1, running = true, timeaffected = false, onceonly = true, funcToCall = function()
			UI.keypressed 'restartstory'
		end
		}
	end
end

function Psychoball:recreate()
	timefactor = 1
	self.pseudoDied = false
	if mouse.isDown('l') then Shot.timer:start() end
	local blink = Timer:new {
		timelimit = .4,
		time = .37,
		running = true,
		funcToCall = function ( timer )
			if timer.timelimit == .4 then
				timer.timelimit = .07
				self.alpha = 0
			else
				timer.timelimit = .4
				self.alpha = 255
			end
		end
	}
	--[[stopblinking]]Timer:new {
		timelimit = 1,
		running = true,
		onceonly = true,
		funcToCall = function()
			blink:remove()
			self.canbehit = true
			self.alpha = 255
		end
	}
end

function Psychoball:keypressed( key )
	auxspeed:add(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v*1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v*1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v*1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v*1.3 or 0)
	)
	self.speed:set(auxspeed)

	if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if keyspressed['lshift'] then
		self.speed:div(2)
	end
end

function Psychoball:joystickpressed( joynum, btn )
	
end

function Psychoball:joystickreleased( joynum, btn )

end

function Psychoball:keyreleased( key )
	auxspeed:sub(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v * 1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v * 1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v * 1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v * 1.3 or 0)
	)
	self.speed:set(auxspeed)

	if auxspeed.x ~= 0 and auxspeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if keyspressed['lshift'] then
		self.speed:div(2)
	end
end

function do_ultrablast()
	for i=1, ultrablast do
		ultrashot:new{
			position = psycho.position:clone(),
			speed = Vector:new{math.cos(math.pi * 2 * i / ultrablast), math.sin(math.pi * 2 * i / ultrablast)}:normalize():mult(3*v, 3*v)
		}:register()
	end
end