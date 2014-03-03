local random, max, floor, abs, ipairs, pairs, unpack = math.random, math.max, math.floor, math.abs, ipairs, pairs, unpack

bossFour = Body:new{
	size = 60,
	width = 400,
	height = 300,
	sizeGrowth = 0,
	maxSize = width,
	basespeed = 1.5 * v,
	maxhealth = 60,
	vulnerable = false,
	shader = Base.circleShader,
	lineWidth = 1,
	ord = 6,
	__type = 'bossFour'
}

Body.makeClass(bossFour)

bossFour.behaviors = {}

function bossFour.behaviors.arriving( self )
	local curdist = self.position:distsqr(width/2, height/2)
	
	if curdist < 1 or curdist > self.prevdist then
		self.currentBehavior = bossFour.behaviors.first
		self.speed:set(0, 0)

		-- create massive wave
		local components = {{}, {}, {}, {}}

		for i = 1, 48 do
			local e = self:getShot()
			components[floor((i - 1) / 12) + 1][((i - 1) % 12) + 1] = e
		end

		local f = Formations.around:new{
			angle = 0,
			target = Vector:new{width/2, height/2},
			angleDelta = Base.toRadians(30),
			distance = 0,
			adapt = false,
			speed = 1.1 * v,
			shootAtTarget = true,
			radius = math.sqrt(width^2 / 4 + height^2 / 4)
		}

		f:applyOn(components[1])
		f.angle = Base.toRadians(7)
		f:applyOn(components[2])
		f.angle = Base.toRadians(14)
		f:applyOn(components[3])
		f.angle = Base.toRadians(21)
		f:applyOn(components[4])

		for _, e in ipairs(components[1]) do e:getWarning() end

		local i = 1
		Timer:new{
			running = true,
			timeLimit = .8,
			callback = function(timer)
				for _, e in ipairs(components[i]) do self:prepare(e) end
				i = i + 1
				if i == 5 then timer:remove() return end
				for _, e in ipairs(components[i]) do e:getWarning() end
			end
		}

		f.radius = width
		f.angle = 0
		f.target = self.position
		f.shootAtTarget = true
		self.form = f

		Timer:new{
			timeLimit = 5,
			onceOnly = true,
			running = true,
			callback = function()
				self.replaceTimer:start()
				self.shootTimer:start(-2)
				self.colors[1]:setAndGo(nil, 0, 100)
				self.colors[2]:setAndGo(nil, 0, 100)
				self.colors[3]:setAndGo(nil, 255, 100)
				--self.colors[4]:setAndGo(nil, 0, 100)
				self.vulnerable = true
			end
		}
	else
		self.prevdist = curdist
	end
end

function bossFour.behaviors.first( self )
	if self.health/bossFour.maxhealth < .75 then
		RecordsManager.addScore(500)

		self.currentBehavior = bossFour.behaviors.second
		
		self.collides = true
		self.speed:set(v/2, 0):rotate(random() * 2 * math.pi)
		self.vulnerable = false
		
		self.colors[1]:setAndGo(nil, 0, 100)
		self.colors[2]:setAndGo(nil, 50, 100)
		self.colors[3]:setAndGo(nil, 25, 100)

		self.colors[1].alsoCall = function()
			self.colors[1].alsoCall = nil
			self.vulnerable = true
			self.health = bossFour.maxhealth * .75
		end
	end
end

function bossFour.behaviors.second( self )
	if self.health/bossFour.maxhealth < .5 then
		RecordsManager.addScore(500)
		
		self.currentBehavior = bossFour.behaviors.tocenter
		
		self.speed:set(width/2, height/2):sub(self.position):normalize():mult(v * .5)
		self.prevdist = self.position:distsqr(width/2, height/2)
		
		self.colors[1]:setAndGo(nil, 122, 100)
		self.colors[2]:setAndGo(nil, 122, 100)
		self.colors[3]:setAndGo(nil, 122, 100)
		self.vulnerable = false
	end
end

function bossFour.behaviors.tocenter( self )
	local curdist = self.position:distsqr(width/2, height/2)
	if curdist < 1 or curdist > self.prevdist then
		self.speed:set(0, 0)
		self.currentBehavior = Base.doNothing
		
		self.doNotAttack = true

		Timer:new{
			timeLimit = 1.1,
			onceOnly = true,
			running = true,
			callback = function()
				self.cage = {}
				local angchange = Base.toRadians(360/30)
				local pos = Vector:new{0, 200}
				local possible = {}

				self.pool:forEachAlive(function(e)
					if e.inBox then possible[#possible + 1] = e end
				end)

				if #possible < 30 then
					local lim = 30 - #possible
					for i = 1, lim do
						local e = self:getShot()
						e.position:set(self.position)
						e.speed:set((random() * v * .3 + v * 1.4) * Base.sign(random() - .5), (random() * v * .3 + v * 1.4) * Base.sign(random() - .5))
						self:prepare(e)
						e.inBox = true
						possible[#possible + 1] = e
					end
				end

				if #self.pool < 50 then
					local lim = 50 - #self.pool
					for i = 1, lim do
						local e = self:getShot()
						e.position:set(self.position)
						e.speed:set((random() * v * .3 + v * 1.4) * Base.sign(random() - .5), (random() * v * .3 + v * 1.4) * Base.sign(random() - .5))
						self:prepare(e)
						e.inBox = true
					end
				end

				for i = 1, 30 do
					local s = possible[i]

					s.ignoreBox = true
					s.onCage = i
					s.target = pos + self.position
					s.prevdist = s.position:distsqr(s.target)
					s.speed:set(s.target):sub(s.position):normalize():mult(bossFour.basespeed)
					s.inBox = true
					pos:rotate(angchange)
					self.cage[#self.cage + 1] = s
				end

				self.poolN = self.poolN + 40
				self.doNotAttack = false
				self.currentBehavior = bossFour.behaviors.third
			end
		}

		Timer:new{
			timeLimit = 2.1,
			onceOnly = true,
			running = true,
			callback = function()
				self.colors[1]:setAndGo(nil, 0, 100)
				self.colors[2]:setAndGo(nil, 122, 100)
				self.colors[3]:setAndGo(nil, 122, 100)

				self.colors[1].alsoCall = function()
					self.colors[1].alsoCall = nil
					self.vulnerable = true
					self.health = bossFour.maxhealth * .5
				end
			end
		}
	end
end

function bossFour.behaviors.third( self )
	for i = 1, 30 do
		local s = self.cage[i]
		if s.prevdist then
			local curdist = s.position:distsqr(s.target)
			if curdist < .2 or curdist > s.prevdist then
				s.position:set(s.target)
				s.prevdist = nil
				s.speed:set(0, 0)
			else
				s.prevdist = curdist
			end
		else
			s.speed:set(0, 0)
		end
	end

	if self.health/bossFour.maxhealth < .25 then
		RecordsManager.addScore(500)

		self.currentBehavior = bossFour.behaviors.gathering
		
		self.sizeGrowth = -20
		self.growToSize = 20
		self.cage = nil
		
		self.shootTimer:remove()
		self.replaceTimer:remove()

		
		self.pool:forEachAlive(function(e)
			if not e.active then
				e:activate()
				e:freeWarning()
				e.divideN = 0
				e:kill()
			else
				e.speed:set(self.position):sub(e.position):normalize():mult(bossFour.basespeed/2)
				e.prevdist = e.position:distsqr(self.position)
			end
		end)
		
		self.vulnerable = false
		self.colors[1]:setAndGo(nil, 122, 100)
		self.colors[2]:setAndGo(nil, 122, 100)
		self.colors[3]:setAndGo(nil, 122, 100)
	end
end

function bossFour.behaviors.gathering ( self )
	self.pool:forEachAlive(function(e)
		if e.prevdist then
			local curdist = e.position:distsqr(self.position)
			if curdist < 1 or curdist > e.prevdist then
				e.speed:set(0, 0)
				e.prevdist = nil
				e.divideN = 0
				e:kill()
			else
				e.prevdist = curdist
			end
		else
			e.speed:set(self.position):sub(e.position):normalize():mult(bossFour.basespeed/2)
			e.prevdist = e.position:distsqr(self.position)
		end
	end)

	if self.growToSize == nil and not self.recharging and self.pool:countAlive() == 0 then
		RecordsManager.addScore(500)
		
		self.currentBehavior = bossFour.behaviors.final

		self.pool:clearAll()
		self.pool = nil

		self.damageCount = nil
		
		self.form.radius = 3
		self.getShot = function()
			return Body.reviveAndCopy((random() < .5 and Enemies.monoguiaball or Enemies.grayball).bodies:getFirstDead(), { score = false })
		end
		
		self.colors[1]:setAndGo(nil, .59 * 225, 100)
		self.colors[2]:setAndGo(nil, .44 * 255, 100)
		self.colors[3]:setAndGo(nil, .9 * 255, 100)
		
		self.colors[1].alsoCall = function()
			self.colors[1].alsoCall = nil
			self.health = bossFour.maxhealth * .25
			self.vulnerable = true
		end
		
		self.shootTimer = Timer:new {
			timeLimit = 1,
			running = true,
			callback = function ()
				self.form.angle = random() * math.pi

				local n = random(14, 22)
				self.form.angleDelta = Base.toRadians(360/n)
				
				local es = {}
				for i = 1, n do
					local e = self:getShot()
					es[#es + 1] = e
					e:register()
				end
				
				self.form:applyOn(es)
			end
		}
	end
end

function bossFour.behaviors.final( self )
	if self.health == 0 then
		RecordsManager.addScore(1000)
		self:kill()
	end
end

function bossFour:update( dt )
	if self.pool then self.pool:update(dt) end

	Body.update(self, dt)
	CircleEffect.update(self, dt)
	self:currentBehavior()

	if self.collides then
		if self.x + self.width/2 > width then self.speed:set(-abs(self.Vx))
		elseif self.x - self.width/2 < 0 then self.speed:set( abs(self.Vx)) end

		if self.y + self.height/2 > height then self.speed:set(nil, -abs(self.Vy))
		elseif self.y - self.height/2 < 0 then  self.speed:set(nil,  abs(self.Vy)) end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

	Shot.bodies:forEachAlive(function(shot)
		if self:collidesWith(shot) then
			shot.explosionEffects = true
			shot:kill()

			if self.health > 0 and self.vulnerable and not self.damageCount or self.damageCount < 8 then
				self.health = self.health - 1
				if self.damageCount then self.damageCount = self.damageCount + 1 end
				local d = self.health/bossFour.maxhealth
				if self.currentBehavior == bossFour.behaviors.first then
					d = (max(d, .75)  -.75) * 4
					self.colors[1]:setAndGo(nil, 255, 1200)
					--self.colors[2] is already correct
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						if self.currentBehavior == bossFour.behaviors.first then
							self.colors[1]:setAndGo(nil, (1 - d) * 255, 400)
							self.colors[3]:setAndGo(nil, d * 255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.second then
					d = (max(d, .5) - .5) * 4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						if self.currentBehavior == bossFour.behaviors.second then
							self.colors[1]:setAndGo(nil, (1 - d) * 255, 400)
							self.colors[2]:setAndGo(nil, d * 50, 400)
							self.colors[3]:setAndGo(nil, d * 25, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.third then
					d = (max(d, .25) - .25) / (.5 - .25)
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						if self.currentBehavior == bossFour.behaviors.third then
							self.colors[1]:setAndGo(nil, (1 - d) * 255, 400)
							self.colors[2]:setAndGo(nil, d * 122, 400)
							self.colors[3]:setAndGo(nil, d * 122, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.final then
					d = max(d, 0) * 4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
						self.colors[1]:setAndGo(nil, .59 * 225 + (1 - d) * .41 * 255, 400)
						self.colors[2]:setAndGo(nil, .44 * 255 * d, 400)
						self.colors[3]:setAndGo(nil, .9 * 255 * d, 400)
					end
					}
				end
			end
		end
	end)
end

function bossFour:draw()
	if self.pool then self.pool:draw() end
	Base.defaultDraw(self)
end

function bossFour:prepare( enemy )
	enemy.update = self.updateFunc
	enemy.kill = self.killFunc
	enemy:register()
	enemy:activate()
end

function bossFour:getShot()
	self.pool.class = (random() < .4 and Enemies.monoguiaball or Enemies.multiball)
	local e = self.pool:getFirstDead():revive()
	e.score = false
	e:deactivate()
	return e
end

function bossFour:grow( n )
	local es = {}

	for i = 1, n do
		local e = self:getShot()
		Enemy.randomizePosition(e)
		e.speed:set(self.position):sub(e.position):normalize():mult(self.basespeed)
		e:getWarning()
		es[#es + 1] = e
	end

	Timer:new{ 
		timeLimit = 1,
		running = true,
		onceOnly = true,
		callback = function()
			if not es[1].alive then return end
			for _, e in ipairs(es) do
				self:prepare(e)
			end
		end
	}
end

function bossFour:revive()
	Body.revive(self)

	self.health = bossFour.maxhealth
	self.position:set(0, 0)
	self.poolN = 50
	self.speed:set(width/2, height/2):normalize():mult(self.basespeed)
	self.prevdist = self.position:distsqr(width/2, height/2)
	self.pool = Group:new{}

	self.currentBehavior = bossFour.behaviors.arriving
	self.updateFunc = function (e, dt)
		if not e.inBox then
			e.speed:set(self.position):sub(e.position):normalize():mult(v * 1.5)
		end
		e:__super().update(e, dt)
		if e.ignoreBox then return end

		if not e.inBox and Base.collides(e, self) then 
			e.inBox = true
			e.speed:set((random() * v * .3 + v * 1.4) * Base.sign(random() - .5), (random() * v * .3 + v * 1.4) * Base.sign(random() - .5))
		end

		if not e.inBox then return end

		if e.x  + e.size > (e.rx or (self.x + self.width/2)) then e.speed:set(-abs(e.Vx))
		elseif e.x - e.size < (e.lx or (self.x - self.width/2)) then e.speed:set( abs(e.Vx)) end

		if e.y + e.size > (e.by or (self.y + self.height/2)) then e.speed:set(nil, -abs(e.Vy))
		elseif e.y - e.size < (e.ty or (self.y - self.height/2)) then e.speed:set(nil,  abs(e.Vy)) end
	end

	self.killFunc = function ( e )
		e:__super().kill(e)
		e.inBox, e.ignoreBox = nil, nil
		if e.onCage then
			-- if there is no more cage
			if not self.cage then
				e.onCage = nil
				return
			end

			local new = nil

			-- finding a suitable shot
			for i = 1, self.pool.length, 1 do
				local b = self.pool[i]
				if b.alive and b.active and not b.onCage and b.inBox then
					new = b
					break
				end 
			end

			if not new then
				new = self:getShot()
				self:prepare(new)
				new.position:set(self.position)
				new.inBox = true
			end

			new.onCage = e.onCage
			new.target = e.target
			new.prevdist = new.position:distsqr(new.target) + 10
			new.speed:set(new.target):sub(new.position):normalize():mult(bossFour.basespeed/2)

			self.cage[e.onCage] = new
			e.onCage = nil
			e.target = nil
			e.prevdist = nil
		end
	end

	self.colors = {VarTimer:new{var = 122}, VarTimer:new{var = 122}, VarTimer:new{var = 122}, VarTimer:new{var = 10}}
	self.coloreffect = ColorManager.getColorEffect(unpack(self.colors))

	self.damageCount = 0

	self.shootTimer = Timer:new{
		timeLimit = .1,
		callback = function()
			-- get one more ball
			if not self.recharging and random() < .2 then self:grow(1) end
			-- shoot something
			if not self.recharging and not self.doNotAttack and random() < .4 then
				local p1 = nil

				-- find a suitable shot in pool
				for i = 1, self.pool.length do
					local e = self.pool[i]
					if e.alive and e.active and e.inBox and not e.ignoreBox then
						p1 = e
						break
					end
				end

				if not p1 then return end
				p1.ignoreBox = true
				p1.speed:set(psycho.position):sub(p1.position):normalize():mult(bossFour.basespeed)
			end
		end
	}

	self.replaceTimer = Timer:new{
		timeLimit = .2,
		callback = function()
 			if not self.recharging and self.damageCount >= 5 and self.pool:countAlive()/self.poolN < .4 then
				local es = {{}, {}, {}, {}, {}, {}}

				for i = 1, 72 do
					local e = self:getShot()
					es[floor((i - 1) / 12) + 1][((i - 1) % 12) + 1] = e
				end

				self.recharging = true
				self.damageCount = 0

				self.form:applyOn(es[1])
				self.form.radius = self.form.radius + 40
				self.form:applyOn(es[2])
				self.form.radius = self.form.radius + 40
				self.form:applyOn(es[3])
				self.form.radius = self.form.radius + 40
				self.form:applyOn(es[4])
				self.form.radius = self.form.radius + 40
				self.form:applyOn(es[5])
				self.form.radius = self.form.radius + 40
				self.form:applyOn(es[6])
				self.form.radius = self.form.radius - 200

				for _, e1 in ipairs(es) do
					for _, e in ipairs(e1) do
						e:getWarning()
					end
				end

				Timer:new {
					timeLimit = 1.5,
					onceOnly = true,
					running = true,
					callback = function()
						if not self.recharging then return end
						self.recharging = false
						for _, e1 in ipairs(es) do
							for _, e in ipairs(e1) do
								self:prepare(e)
							end
						end
					end
				}
			end
		end
	}

	return self
end

function bossFour:kill()
	Body.kill(self)
	self.shootTimer:remove()
	Effect.createEffects(self, 200)
	for i = 1, 4 do
		self.colors[i]:remove()
	end
end