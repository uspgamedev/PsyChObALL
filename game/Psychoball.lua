local psychoSizeDiff = 9
local ultraShots
local ultraTimer = nil

Psychoball = CircleEffect:new {
	size   = 23 - psychoSizeDiff,
	sizeDiff = psychoSizeDiff,
	maxSize = width,
	mode   = 'fill',
	variance = 0,
	sizeGrowth = 0,
	alpha = 255,
	lives = 10,
	index = false,
	canBeHit = true,
	pseudoDied = false,
	ultraCounter = 0,
	continuesUsed = 0,
	visible = true,
	__type = 'Psychoball'
}

Body.makeClass(Psychoball)

function Psychoball.init()
	ultraTimer = Timer:new {
		timeLimit  = .02,
		persistent = true
	}

	local maxShots = 42 -- maximum number of shots on ultrablast
	function ultraTimer:callback() -- adds more shots to ultrablast
		if ultraShots < maxShots then
			ultraShots = ultraShots + 1
		end
		if ultraShots == maxShots then
			self:remove()
			psycho.sizeGrowth = 0
		end
	end

	function ultraTimer:handleReset()
		psycho.sizeGrowth = 0
		self:remove()
	end
end

local max, min = math.max, math.min
function Psychoball:update(dt)
	if self.pseudoDied or DeathManager.gameLost or paused then return end
	RecordsManager.update(dt)

	self.blastTime = self.blastTime + dt

	if self.blastTime >= 30 and state == survival then
		self.blastTime = self.blastTime - 30
		self.ultraCounter = self.ultraCounter + 1
	end

	if usingjoystick then
		self.speed:set(joystick.getAxis(1, 1), joystick.getAxis(1, 2)):mult(v*1.3, v*1.3)
		if not Shot.timer.running and (joystick.getAxis(1, 3) ~= 0 or joystick.getAxis(1, 4) ~= 0) then Shot.timer:start(Shot.timer.timeLimit) end
		if Shot.timer.running and joystick.getAxis(1, 3) == 0 and joystick.getAxis(1, 4) == 0 then Shot.timer:stop() end
	end

	Body.update(self, dt)

	self.position:set(
		max(self.size + psychoSizeDiff, min(width - self.size - psychoSizeDiff, self.position[1])),
		max(self.size + psychoSizeDiff, min(height - self.size - psychoSizeDiff, self.position[2]))
	)

	if Game.keyboard.isPressed[' '] and not self.chargingUltrablast and self.ultraCounter > 0 then
		self:startBlast()
	end

	if not Game.keyboard.isPressed[' '] and self.chargingUltrablast then
		self:releaseBlast()
	end

	if self.sizeGrowth < 0 and self.size + psychoSizeDiff < 23 then
		self.lineWidth = 6
		self.size = 23 - psychoSizeDiff
		self.sizeGrowth = 0
	end

	CircleEffect.update(self, dt)
end


function Psychoball:startBlast()
	self.ultraCounter = self.ultraCounter - 1
	self.chargingUltrablast = true
	ultraShots = 10
	self.sizeGrowth = 17
	self.lineWidth = 6
	ultraTimer:register()
	ultraTimer:start(0)
end

function Psychoball:releaseBlast()
	ultraTimer:remove()
	self.chargingUltrablast = false
	self.sizeGrowth = -300
	doUltrablast()
end

function Psychoball:addLife()
	self.lives = self.lives + 1
	-- do something here maybe
end

function Psychoball:removeLife()
	self.lives = self.lives - 1
	-- do something here maybe
end

function Psychoball:draw()
	if self.pseudoDied or not self.visible or Cheats.invisible then return end
	if not Cheats.image.enabled then graphics.setShader(Base.circleShader) end
	self.size = self.size + psychoSizeDiff
	Base.defaultDraw(self)
	self.size = self.size - psychoSizeDiff
end

function Psychoball:handleDelete()
	Shot.timer:stop() -- stops shooting
	self.speed:set(0,0) -- stops moving
	--self.sizeGrowth = -300
end

function Psychoball:recreate()
	timeFactor = 1
	self.pseudoDied = false
	self.visible = true

	if mouse.isDown('l') then Shot.timer:start() end
	local blink = Timer:new {
		timeLimit = .4,
		time = .37,
		running = true,
		callback = function ( timer )
			if timer.timeLimit == .4 then
				timer.timeLimit = .07
				self.alpha = 0
			else
				timer.timeLimit = .4
				self.alpha = 255
			end
		end
	}

	-- stop blinking
	Timer:new {
		timeLimit = 1,
		running = true,
		onceOnly = true,
		callback = function()
			blink:remove()
			self.canBeHit = true
			self.alpha = 255
		end
	}
end

local auxSpeed = Vector:new {0, 0}
function Psychoball:revive()
	Body.revive(self)

	auxSpeed:set(0, 0)

	self.blastTime = 0
	self.chargingUltrablast = false
	self.visible = true

	self.lives = Psychoball.lives

	if self.pseudoDied then
		self.pseudoDied = false
		paintables.deathEffects.bodies = nil
		paintables.deathEffects = nil
	end

	if not self.canBeHit then
		self.canBeHit = true
		self.alpha = 255
	end

	return self
end

function Psychoball:keyPressed( key )
	auxSpeed:add(
		((key == 'left' and not Game.keyboard.isPressed['a'] or key == 'a' and not Game.keyboard.isPressed['left']) and -v*1.3 or 0) 
			+ ((key == 'right' and not Game.keyboard.isPressed['d'] or key == 'd' and not Game.keyboard.isPressed['right']) and v*1.3 or 0),
		((key == 'up' and not Game.keyboard.isPressed['w'] or key == 'w' and not Game.keyboard.isPressed['up']) and -v*1.3 or 0) 
			+ ((key == 'down' and not Game.keyboard.isPressed['s'] or key == 's' and not Game.keyboard.isPressed['down']) and v*1.3 or 0)
	)
	self.speed:set(auxSpeed)

	if auxSpeed.x ~= 0 and auxSpeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if Game.keyboard.isPressed['lshift'] then
		self.speed:div(2)
	end
end

function Psychoball:joystickPressed( joynum, btn )
	
end

function Psychoball:joystickReleased( joynum, btn )

end

function Psychoball:keyReleased( key )
	auxSpeed:sub(
		((key == 'left' and not Game.keyboard.isPressed['a'] or key == 'a' and not Game.keyboard.isPressed['left']) and -v * 1.3 or 0) 
			+ ((key == 'right' and not Game.keyboard.isPressed['d'] or key == 'd' and not Game.keyboard.isPressed['right']) and v * 1.3 or 0),
		((key == 'up' and not Game.keyboard.isPressed['w'] or key == 'w' and not Game.keyboard.isPressed['up']) and -v * 1.3 or 0) 
			+ ((key == 'down' and not Game.keyboard.isPressed['s'] or key == 's' and not Game.keyboard.isPressed['down']) and v * 1.3 or 0)
	)
	self.speed:set(auxSpeed)

	if auxSpeed.x ~= 0 and auxSpeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if Game.keyboard.isPressed['lshift'] then
		self.speed:div(2)
	end
end

function Psychoball.additionalDrawing()
	if Psychoball.turnLightsOff then
		Base.turnLightsOffShader:send('psychoRelativePos', {psycho.x/width, psycho.y/width})
		graphics.setShader(Base.turnLightsOffShader)
		graphics.setColor(0, 0, 0, 255)
		graphics.draw(Base.pixel, 0, 0, 0, width, width)
		graphics.setShader(Base.circleShader)
	end
end

local sin, cos, pi = math.sin, math.cos, math.pi
function doUltrablast()
	for i = 1, ultraShots do
		local s = Shot.bodies:getFirstDead():revive()
		s.position:set(psycho.position)
		s.speed:set(cos(pi * 2 * i / ultraShots), sin(pi * 2 * i / ultraShots)):normalize():mult(3 * v, 3 * v)
		s.isUltraShot = true
		s:register()
	end
end