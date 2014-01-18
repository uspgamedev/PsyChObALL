local psychoSizeDiff = 9

local ultraTimer = nil

Psychoball = CircleEffect:new {
	size   = 23 - psychoSizeDiff,
	sizeDiff = psychoSizeDiff,
	maxsize = width,
	mode   = 'fill',
	variance = 0,
	sizeGrowth = 0,
	alpha = 255,
	lives = 10,
	index = false,
	changesimage = true,
	canBeHit = true,
	pseudoDied = false,
	spriteBatch = false,
	ultraCounter = 0,
	continuesUsed = 0,
	__type = 'Psychoball'
}

Body.makeClass(Psychoball)

function Psychoball.init()
	ultraTimer = Timer:new {
		timelimit  = .02,
		persistent = true
	}

	local ultrablastmax = 42 -- maximum number of shots on ultrablast
	function ultraTimer:funcToCall() -- adds more shots to ultrablast
		if ultrablast < ultrablastmax then
			ultrablast = ultrablast + 1
		end
		if ultrablast == ultrablastmax - 1 then
			psycho.sizeGrowth = 0
		end
	end

	function ultraTimer:handleReset()
		self:stop()
	end
end

local max, min = math.max, math.min
function Psychoball:update(dt)
	if self.pseudoDied or DeathManager.gameLost then return end
	RecordsManager.update(dt)

	self.blastTime = self.blastTime + dt

	if self.blastTime >= 30 and state == survival then
		self.blastTime = self.blastTime - 30
		self.ultraCounter = self.ultraCounter + 1
	end

	if usingjoystick then
		self.speed:set(joystick.getAxis(1, 1), joystick.getAxis(1, 2)):mult(v*1.3, v*1.3)
		if not Shot.timer.running and (joystick.getAxis(1, 3) ~= 0 or joystick.getAxis(1, 4) ~= 0) then Shot.timer:start(Shot.timer.timelimit) end
		if Shot.timer.running and joystick.getAxis(1, 3) == 0 and joystick.getAxis(1, 4) == 0 then Shot.timer:stop() end
	end

	Body.update(self, dt)

	self.position:set(
		max(self.size + psychoSizeDiff, min(width - self.size - psychoSizeDiff, self.position[1])),
		max(self.size + psychoSizeDiff, min(height - self.size - psychoSizeDiff, self.position[2]))
	)

	if keyspressed[' '] and not ultraTimer.running and self.ultraCounter > 0 then
		self:startBlast()
	end

	if not keyspressed[' '] and ultraTimer.running then
		self:releaseBlast()
	end

	if self.sizeGrowth < 0 and self.size + psychoSizeDiff < 23 then
		self.linewidth = 6
		self.size = 23 - psychoSizeDiff
		self.sizeGrowth = 0
	end

	CircleEffect.update(self, dt)
end


function Psychoball:startBlast()
	self.ultraCounter = self.ultraCounter - 1
	ultrablast = 10
	self.sizeGrowth = 17
	self.linewidth = 6
	ultraTimer:start()
end

function Psychoball:releaseBlast()
	ultraTimer:stop()
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
	if self.pseudoDied or DeathManager.gameLost then return end
	self.size = self.size + psychoSizeDiff
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alphaFollows and self.alphaFollows.var or self.alpha, self.coloreffect))
	graphics.circle(self.mode, self.position[1], self.position[2], self.size)
	self.size = self.size - psychoSizeDiff
end

function Psychoball:handleDelete()
	Shot.timer:stop() -- stops shooting
	self.speed:set(0,0) -- stops moving
	--self.sizeGrowth = -300
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

	-- stop blinking
	Timer:new {
		timelimit = 1,
		running = true,
		onceOnly = true,
		funcToCall = function()
			blink:remove()
			self.canBeHit = true
			self.alpha = 255
		end
	}
end

local auxSpeed = Vector:new {0, 0}
function Psychoball:reset()
	auxSpeed:reset()
	self.blastTime = 0
end

function Psychoball:keyPressed( key )
	auxSpeed:add(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v*1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v*1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v*1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v*1.3 or 0)
	)
	self.speed:set(auxSpeed)

	if auxSpeed.x ~= 0 and auxSpeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if keyspressed['lshift'] then
		self.speed:div(2)
	end
end

function Psychoball:joystickPressed( joynum, btn )
	
end

function Psychoball:joystickReleased( joynum, btn )

end

function Psychoball:keyReleased( key )
	auxSpeed:sub(
		((key == 'left' and not keyspressed['a'] or key == 'a' and not keyspressed['left']) and -v * 1.3 or 0) 
			+ ((key == 'right' and not keyspressed['d'] or key == 'd' and not keyspressed['right']) and v * 1.3 or 0),
		((key == 'up' and not keyspressed['w'] or key == 'w' and not keyspressed['up']) and -v * 1.3 or 0) 
			+ ((key == 'down' and not keyspressed['s'] or key == 's' and not keyspressed['down']) and v * 1.3 or 0)
	)
	self.speed:set(auxSpeed)

	if auxSpeed.x ~= 0 and auxSpeed.y ~= 0 then 
		self.speed:div(sqrt2)
	end

	if keyspressed['lshift'] then
		self.speed:div(2)
	end
end

function Psychoball.additionalDrawing()
	if Psychoball.turnLightsOff then
		Base.turnLightsOffShader:send('psychoRelativePos', {psycho.x/width, psycho.y/width})
		graphics.setPixelEffect(Base.turnLightsOffShader)
		graphics.setColor(0, 0, 0, 255)
		graphics.draw(Base.pixel, 0, 0, 0, width, width)
		graphics.setPixelEffect(Base.circleShader)
	end
end

function doUltrablast()
	for i=1, ultrablast do
		Shot:new{
			position = psycho.position:clone(),
			speed = Vector:new{math.cos(math.pi * 2 * i / ultrablast), math.sin(math.pi * 2 * i / ultrablast)}:normalize():mult(3*v, 3*v),
			isUltraShot = true
		}:register()
	end
end