seeker = Body:new {
	size = 20,
	timeOut = 10,
	seek = true,
	health = 3,
	bodies = Group:new{},
	__type = 'seeker'
}

Body.makeClass(seeker)

function seeker:revive( timeOut, exitpos )
	Body.revive(self)

	self.timeOut = timeOut
	self.exitPosition = Base.clone(exitpos)

	self.health = seeker.health
	self.seek = true

	self.speedN = math.random(0.8 * v - 30, 0.8 * v)
	self.colors = {{var = .88 * 255}, {var = .66 * 255}, {var = .37 * 255}, 30}
	self.coloreffect = ColorManager.getColorEffect(unpack(self.colors))
	self.acceleration = Vector:new{0, 0}

	return self
end

function seeker:start()
	Body.start(self)

	self.timeOutTimer = Timer:new{
		timeLimit = self.timeOut,
		onceOnly = true,
		running = true,
		callback = function()
			self.seek = false
			self.speed:set(self.exitPosition):sub(self.position):normalize():mult(self.speedN)
			self.acceleration:set(0,0)
		end
	}
end

seeker.draw = Base.defaultDraw

local auxVec = Vector:new{}
local sqrt, min, max = math.sqrt, math.min, math.max
function seeker.bodies:update( dt )
	local g = seeker.bodies
	for i = 1, g.length, 1 do
		if g[i].alive and g[i].active then
			for j = i + 1, g.length, 1 do
				if g[j].alive and g[j].active then
					local sek1, sek2 = g[i], g[j]
					auxVec:set(sek1.position):sub(sek2.position)
					local len2 = auxVec:lengthsqr()
					if len2 < 200 * 200 then
						len2 = sqrt(len2)
						auxVec:mult((200 - len2) / len2):mult(25)
						sek2.acceleration:add(auxVec)
						sek1.acceleration:add(auxVec:negate())
					end
				end
			end
		end
	end

	Group.update(self, dt)
end

function seeker:update( dt )

	if self.seek and not psycho.pseudoDied and psycho.canBeHit then
		auxVec:set(psycho.position):sub(self.position)

		local len = min(auxVec:length(), 300)
		auxVec:mult((400 - len)/len):mult(60)
		self.acceleration:add(auxVec)
		self.speed:add(auxVec:set(self.acceleration):mult(dt))
		self.acceleration:set(0, 0)
		
		local spd = self.speed:lengthsqr()
		if spd > self.speedN * self.speedN then
			self.speed:mult(self.speedN/sqrt(spd))
		end

		self.position:add(auxVec:set(self.speed):mult(dt))
	else
		Body.update(self, dt)
	end

	Shot.bodies:forEachAlive(function(shot)
		if self.alive and self:collidesWith(v) then
			self:manageShotCollision(v)
		elseif self.alive and self.seek then
			auxVec:set(self.position):sub(shot.position)
			local len = auxVec:length()
			if len < 200 then
				len = max(len, 20)
				auxVec:mult((200 - len)/len):mult(80)
				self.acceleration:add(auxVec)
			end
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

function seeker:manageShotCollision( shot )
	shot.explosionEffects = false
	shot:kill()

	self.health = self.health - 1
	if self.health == 0 then
		self.causeOfDeath = "shot"
		self:kill()
	end

	local d = self.health/seeker.health
	self.colors[1].var = .88 * 255 + (1 - d) * .22 * 255
	self.colors[2].var = .66 * 255 * d
	self.colors[3].var = .37 * 255 * d
end

function seeker:kill()
	Body.kill(self)

	Effect.createEffects(self, 40)

	self.timeOutTimer:remove()
	self.timeOutTimer = nil
end