local max, min, abs, random, pairs, unpack, next, ipairs = math.max, math.min, math.abs, math.random, pairs, unpack, next, ipairs

bossThree = Body:new {
	size = 50,
	yellowGuySize = 80,
	sizeGrowth = 0,
	baseSpeed = 1.4 * v,
	maxHealth = 13,
	yellowGuyHealth = 60,
	vulnerable = true,
	segmentsN = 9,
	maxSize = width,
	visible = true,
	ord = 6,
	__type = 'bossThree'
}

Body.makeClass(bossThree)

bossThree.behaviors = {}

function bossThree.behaviors.first( self )
	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		if s.target == 5 then -- cycle through targets
			s.target = 1
			s.prevdist = width - 120
			s.position:set(60, 60)
			bossThree.goRight(s)
		end
	end

	if self.last - self.first < bossThree.segmentsN - 3 and ((self.y > height/2 and self.x < width/4) or (self.y <= height/2 and self.x > 3*width/4))  then
		RecordsManager.addScore(750)
		local t = self.segments[self.first].target
		for i = self.first + 1, self.last, 1 do
			if self.segments[i].target ~= t then return end
		end
		-- all segments have the same target

		self.shootTimer.timeLimit = self.shootTimer.timeLimit/1.4
		self.currentBehavior = Base.doNothing
		self.snakeMode = true

		local s = Base.sign(self.segments[self.first].speed.x)
		local x = self.x + s * 2
		local t = self.segments[self.first].target
		-- clear path
		for i = t, 4, 1 do self.path[i] = nil end

		self.path[#self.path + 1] = {x, self.y}
		for i = self.first, self.last, 1 do
			local s = self.segments[i]
			s.prevdist = abs(x - s.position.x)
		end

		local y = self.y
		local dir = s == 1 and bossThree.goRight or bossThree.goLeft

		for i = 1, 10 do
			-- creating 'stair' movement
			y = y - 144
			if y < 0 then y = y + height end
			self.path[#self.path + 1] = {x, y, onDeparture = bossThree.goUp}
			x = x + s * 216
			if x >= width then x = x - width end
			if x < 0 then x = x + width end
			self.path[#self.path + 1] = {x, y, onDeparture = dir}
		end

		self.path[#self.path].onArrival = function(s)
			self.path[#self.path].onArrival = nil
			
			-- create food when first segment arrives
			local food = bossThree.food.bodies:getFirstDead():revive()
			food.position:set(s.speed):normalized():mult(width/8, width/8):add(s.position):set(nil, height/2)
			food.position.x = food.position.x % width
			food:register()
			
			self.path[#self.path + 1] = {food.position.x, self.y, onDeparture = dir}
			self.path[#self.path + 1] = {food.position.x, food.position.y}
			self.path[#self.path].onArrival = function ( s )
				self.path[#self.path].onArrival = nil
				self.currentBehavior = bossThree.behaviors.second
			end
			
			self.currentBehavior = Base.doNothing

			self.spawnfood = Timer:new{
				timeLimit = random()*7 + 9,
				running = true,
				callback = function(timer)
					timer.timeLimit = random()*7 + 9

					-- does not spawn food if snake is too big
					if self.last - self.first + 1 >= 7 then return end

					-- creates food the farthest away possible from the snake
					local f = bossThree.food.bodies:getFirstDead():revive()
					f.position:set(self.position):add(width/2, height/2)
					f.position.x = max(min(f.position.x % width, width - 100), 100)
					f.position.y = max(min(f.position.y % height, height - 100), 100)
					f:register()
				end
			}
		end
	end
end

function bossThree.behaviors.second( self )
	self:followFoodOrPsycho()

	if self.first == self.last then
		-- if there's only one segment
		RecordsManager.addScore(1000)

		local speedbak = self.speed:clone()
		self.speed:set(0, 0)

		Timer:new{
			timeLimit = 1.5,
			onceOnly = true,
			running = true,
			callback = function()
				self.speed:set(speedbak)
				self.health = bossThree.yellowGuyHealth
			end
		}

		-- stop shooting
		self.shootTimer:remove()
		self.shootTimer = nil

		self.health =  bossThree.yellowGuyHealth
		self.sizeGrowth = 10
		self.growToSize = self.yellowGuySize
		
		self.colors[1]:setAndGo(nil, 255, 80)
		self.colors[2]:setAndGo(nil, 255, 80)
		self.colors[3]:setAndGo(nil, 0, 80)
		
		-- no more paths, just one segment, yellowGuy
		self.path = nil
		self.segments = {self.segments[self.first]}
		self.first, self.last = 1, 1
		self.yellowGuy = self.segments[1]

		-- no more need for gambs
		self.gambiarra:remove()
		self.gambiarra = nil

		self.position = self.yellowGuy.position
		self.speed = self.yellowGuy.speed
		self.follow = self.yellowGuyFollow
		self.handleHealthLoss = bossThree.yellowGuyHealthLoss

		bossThree.food:clear()

		do
			-- yellow guy mouth stuff
			self.yellowGuyAngle = VarTimer:new{var = self.Vx > 0 and 0 or self.Vx < 0 and math.pi or self.Vy > 0 and math.pi/2 or 3*math.pi/2}
			self.yellowGuyAngle.pausable = true

			local ang = 0
			self.yellowGuyTimer = Timer:new{
				running = true,
				timeLimit = nil, -- run all the time
				timecount = 0,
				increasing = true,
				limit = .1,
				change = Base.toRadians(20),
				pause = false,
				callback = function(t, dt)
					t.timecount = t.timecount + dt
					if t.timecount > t.limit then 
						if t.pause then t:stop() t.pauseCallback() return end
						t.timecount = 0 
						t.increasing = not t.increasing 
					end
					ang = (t.increasing and t.timecount or t.limit - t.timecount) * t.change / t.limit
				end
			}

			self.invertedStencil = function() graphics.arc('fill', self.x, self.y, self.size, self.yellowGuyAngle.var - ang, self.yellowGuyAngle.var + ang) end
		end

		local cs = {{255, 0, 0}, {255, 255, 255}, {230, 143, 172}, {205, 140, 0}}
		for _, color in ipairs(cs) do
			local g = bossThree.ghost.bodies:getFirstDead():revive()
			g:register()
			-- change to set position later
			Enemy.randomizePosition(g)
			g.speed:set(Base.sign(random() - .5) * random(v * .7, v), Base.sign(random() - .5) * random(v * .7, v))
			g.coloreffect = ColorManager.getColorEffect(unpack(color))
		end
		
		self.currentBehavior = bossThree.behaviors.third -- change behavior
	end
end

function bossThree.behaviors.third( self )
	self:followFoodOrPsycho()

	if self.health/bossThree.yellowGuyHealth < .5 then
		RecordsManager.addScore(1000)

		local speedbak = self.speed:clone()
		self.speed:set(0, 0) -- stop

		self.currentBehavior = Base.doNothing
		self.vulnerable = false

		Timer:new{ timeLimit = 1, running = true, onceOnly = true, callback = function()
				bossThree.food:clear()
				
				-- almost die
				local ygTimer = self.yellowGuyTimer
				ygTimer.increasing = true
				ygTimer.limit = 1
				ygTimer.change = 3 * math.pi/4
				ygTimer.pause = true
				ygTimer.timecount = 0

				ygTimer.pauseCallback = function()
					
					-- go back
					ygTimer:start()
					ygTimer.timecount = 0
					ygTimer.pause = true
					ygTimer.increasing = false
					
					-- rage colors
					self.colors[1]:setAndGo(nil, .94 * 255, 40)
					self.colors[2]:setAndGo(nil, .86 * 255, 40)
					self.colors[3]:setAndGo(nil, .51 * 255, 40)
					
					ygTimer.pauseCallback = function()

						-- go back to normal eating
						ygTimer:start()
						ygTimer.timecount = 0
						ygTimer.pause = false
						ygTimer.increasing = true
						ygTimer.limit = .1
						ygTimer.change = Base.toRadians(20)
						ygTimer.pauseCallback = nil

						self.currentBehavior = bossThree.behaviors.fourth -- change behavior

						-- start walking again, now on rage
						self.vulnerable = true
						self.yellowGuy.onRage = true
						self.speed:set(speedbak)
						self.health = bossThree.yellowGuyHealth * .5
						self.spawnfood.time = self.spawnfood.timeLimit
					end
				end
			end
		}
	end
end

function bossThree.behaviors.fourth( self )
	self:followFoodOrPsycho()
	if self.health == 0 then
		RecordsManager.addScore(1500)

		self.speed:set(0, 0)
		self.currentBehavior = Base.doNothing
		self.vulnerable = false
		
		Timer:new{ timeLimit = 1, running = true, onceOnly = true, callback = function()
				bossThree.food:clear()
				local ygTimer = self.yellowGuyTimer

				-- 'die'
				ygTimer.increasing = true
				ygTimer.limit = 1
				ygTimer.change = math.pi
				ygTimer.pause = true
				ygTimer.timecount = 0

				ygTimer.pauseCallback = function()
					self:pseudoKill()
					-- pseudo kill self, but not really

					bossThree.ghost.bodies:forEachAlive(function(ghost)
						ghost.ring.sizeGrowth = 30
						ghost.ring.growToSize = ghost.size * 3
					end)

					Timer:new{
						running = true,
						onceOnly = true,
						timeLimit = 2,
						callback = function()
							local change = VarTimer:new{var = 0}
							local c = ColorManager.getColorEffect({var = 122}, {var = 122}, {var = 122}, change)
							change:setAndGo(0, 255, 80)
							change.alsoCall = function() change:remove() end
							bossThree.ghost.bodies:forEachAlive(function(ghost)
								ghost.ring.coloreffect = c
								ghost.vulnerable = true
								ghost.shootTimer:start()
							end)
						end
					}
				end
			end
		}
	end
end

function bossThree:followFoodOrPsycho()
	local food = bossThree.food.bodies:getFirstAlive()
	if food then
		if not food.eaten then
			self:follow(food.position)
		elseif psycho.canBeHit then self:follow(psycho.position) end
	else
		if psycho.canBeHit then self:follow(psycho.position) end
	end
end

function bossThree:revive()
	Body.revive(self)

	self.follow = self.defaultFollow
	self.handleHealthLoss = self.defaultHealthLoss
	self.currentBehavior = bossThree.behaviors.first

	local n = self.segmentsN
	self.position = Vector:new{-60, 60}
	self.path = {{width - 60, 60}, {width - 60, height - 60}, {60, height - 60}, {60, 60}}
	self.segments = {}
	self.speedvalue = spd

	self.colors = {VarTimer:new{var = 0}, VarTimer:new{var = 255}, VarTimer:new{var = 0}, VarTimer:new{var = 70}, VarTimer:new{var = 50}}
	self.coloreffect = ColorManager.getColorEffect(unpack(self.colors))

	local speed = Vector:new(Base.clone(self.path[1])):sub(self.position):normalize()
	local diff = speed * (self.size * 2)
	speed:mult(bossThree.baseSpeed)
	self.speed:set(speed)

	self.health = bossThree.maxHealth
	self.first, self.last = 1, n
	self.segments[1] = { speed = speed, position = self.position, extraposition = Vector:new{0,0}, prevdist = self.position:distsqr(self.path[1]), target = 1 }

	for i = 2, n, 1 do
		local s = {}
		s.speed = speed:clone()
		s.position = self.position - ((i - 1) * diff)
		s.prevdist = s.position:distsqr(self.path[1])
		s.target = 1
		s.extraposition = Vector:new{0, 0}
		self.segments[i] = s
	end

	do
		local s2 = self.size * 2
		self.gambiarra = Timer:new{ -- gambiarra (arruma os segmentos da snake se necessário)
			timeLimit = .1,
			running = true,
			callback = function()
				local prev = nil
				for i = self.first, self.last, 1 do
					local s = self.segments[i]
					if prev and prev.target == s.target and abs(prev.position:distsqr(s.position) - s2 * s2) < s2 * s2 then
						s.position:set(prev.position):sub(prev.speed:normalized():mult(s2))
					end
					prev = s
				end
			end
		}
	end

	self.shootTimer = Timer:new{
		timeLimit = .8
	}

	function self.shootTimer.callback()
		if not psycho.canBeHit then return end

		local e = Enemies.grayball.bodies:getFirstDead():revive()
		e.position:set(self.position)
		e.speed:set(psycho.position):sub(self.position):normalize():mult(2 * v, 2 * v)
		e:register()
	end

	self.hide = false

	return self
end

function bossThree:start()
	Body.start(self)

	self.shootTimer:start(-3)
end

function bossThree:defaultFollow( pos )
	local s1 = self.segments[self.first]
	if s1.target <= #self.path then return end
	if s1.speed.x ~= 0 then
		if abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			local gd, gu = bossThree.goDown, bossThree.goUp
			local newf = dist > 0 and (dist > height/2 and gu or gd) or (dist < -height/2 and gd or gu)
			local curf = s1.speed.x > 0 and bossThree.goRight or bossThree.goLeft
			local p = {s1.position:unpack()}
			p.onDeparture = curf
			p[1] = p[1] + Base.sign(s1.speed.x)
			self.path[s1.target + 1] = {p[1], pos.y, onDeparture = newf}
			self.path[s1.target] = p

			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if s.target == s1.target then
					s.prevdist = abs(s.position[1] - p[1])
				end
			end
		end
	else
		if abs(pos.y - self.y) < 9 then
			local dist = pos.x - self.x
			local gr, gl = bossThree.goRight, bossThree.goLeft
			local newf = dist > 0 and (dist > width/2 and gl or gr) or (dist < -width/2 and gr or gl)
			local curf = s1.speed.y > 0 and bossThree.goDown or bossThree.goUp
			local p = {s1.position:unpack()}
			p.onDeparture = curf
			p[2] = p[2] + Base.sign(s1.speed.x)
			self.path[s1.target + 1] = {pos.x, p[2], onDeparture = newf}
			self.path[s1.target] = p

			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if s.target == s1.target then
					s.prevdist = abs(s.position[2] - p[2])
				end
			end
		end
	end
end

function  bossThree:yellowGuyFollow( pos )
	if self.Vx ~= 0 then
		if abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			if (dist > 0 and dist < height/2) or (dist < 0 and dist < -height/2) then
				self.speed:set(0, bossThree.baseSpeed)
				self.yellowGuyAngle:setAndGo(nil, Base.toRadians(90), Base.toRadians(100))
			else
				self.yellowGuyAngle.var = self.Vx > 0 and Base.toRadians(360) or Base.toRadians(180)
				self.yellowGuyAngle:setAndGo(nil, Base.toRadians(270), Base.toRadians(100))
				self.speed:set(0, -bossThree.baseSpeed)
			end
		end
	else
		if abs(pos.y - self.y) < 9 then
			local dist = pos.x - self.x
			if (dist > 0 and dist < width/2) or (dist < 0 and dist < -width/2) then
					self.yellowGuyAngle.var = self.Vy > 0 and Base.toRadians(90) or Base.toRadians(-90)
					self.yellowGuyAngle:setAndGo(nil, Base.toRadians(0), Base.toRadians(100))
					self.speed:set(bossThree.baseSpeed, 0)
				else
					self.speed:set(-bossThree.baseSpeed, 0)
					self.yellowGuyAngle:setAndGo(nil, Base.toRadians(180), Base.toRadians(100))
			end
		end
	end
end

function bossThree.setspeed( speed )
	return function(s) s.speed:set(speed) end
end

bossThree.goUp    = bossThree.setspeed {0, -bossThree.baseSpeed}
bossThree.goDown  = bossThree.setspeed {0,  bossThree.baseSpeed}
bossThree.goLeft  = bossThree.setspeed {-bossThree.baseSpeed, 0}
bossThree.goRight = bossThree.setspeed { bossThree.baseSpeed, 0}

function bossThree:draw()
	bossThree.ghost.bodies:draw()
	bossThree.food.bodies:draw()
	if self.hide then return end
	if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end

	if self.first <= self.last then
		local s = self.segments[self.first]
		graphics.setColor(ColorManager.getComposedColor(self.variance, nil, self.coloreffect))
		if self.yellowGuy then
			graphics.setPixelEffect()
			graphics.setInvertedStencil(self.invertedStencil)
			love.graphics.circle(self.mode, s.position[1] * ratio, s.position[2] * ratio, self.size * ratio)
		else
			graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		end

		graphics.translate(unpack(s.extraposition))

		if self.yellowGuy then 
			graphics.setInvertedStencil(self.invertedStencil)
			love.graphics.circle(self.mode, s.position[1] * ratio, s.position[2] * ratio, self.size * ratio)
		else
			graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		end

		graphics.translate(-s.extraposition[1], -s.extraposition[2])
		
		if self.yellowGuy then 
			graphics.setInvertedStencil()
			if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end
		end
	end

	for i = self.first + 1, self.last, 1 do
		local s = self.segments[i]
		graphics.setColor(ColorManager.getComposedColor(self.variance, nil, ColorManager.noLSDEffect))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)

		graphics.translate(unpack(s.extraposition))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.translate(-s.extraposition[1], -s.extraposition[2])
	end
end

local auxVec = Vector:new{}

function bossThree:update( dt )
	bossThree.ghost.bodies:update(dt)
	bossThree.food.bodies:update(dt)
	if self.hide then return end

	self:currentBehavior()
	CircleEffect.update(self, dt)

	for i = self.first, self.last, 1 do
		local s = self.segments[i]

		s.position:add(auxVec:set(s.speed):mult(dt))

		Shot.bodies:forEachAlive(function(shot)
			if Base.collides(s.position, self.size, shot.position, shot.size) then
				shot.explosionEffect = true
				shot:kill()

				if i == self.first and self.health > 0 and self.vulnerable then 
					self:handleHealthLoss()
				end
			end
		end)

		if psycho.canBeHit and not DeathManager.gameLost and Base.collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.causeOfDeath = "shot"
			DeathManager.manageDeath()
		end

		if self.snakeMode then
			if s.position[1] < self.size or s.position[1] > width - self.size then
				if s.position[1] <= -3 or s.position[1] >= width + 3 then
					s.position[1] = (s.position[1] < width/2 and width - 3 or 3)
				end
				s.extraposition:set(s.position[1] < width/2 and width or -width, nil)
			else
				s.extraposition:set(0, nil)
			end

			if s.position[2] < self.size or s.position[2] > height - self.size then
				if s.position[2] <= -3 or s.position[2] >= height + 3 then
					s.position[2] = (s.position[2] < height/2 and height - 3 or 3)
				end
				s.extraposition:set(nil, s.position[2] < height/2 and height or -height)
			else
				s.extraposition:set(nil, 0)
			end
		end
			
		if self.path and s.target <= #self.path then
			local p = self.path[s.target]
			local curdist = s.position:distsqr(p)

			if curdist < 1 or (curdist < 100 and curdist > s.prevdist) then
				s.prevdist = nil
				s.position:set(p)
				s.target = s.target + 1

				if p.onArrival then p.onArrival(s) end
				
				if s.target <= #self.path then 
					p = self.path[s.target]
					s.prevdist = s.position:distsqr(p)
					if p.onDeparture then p.onDeparture(s)
					else s.speed:set(p):sub(s.position):normalize():mult(bossThree.baseSpeed) end
				end
			else 
				s.prevdist = curdist
			end
		end
	end
end

function bossThree:defaultHealthLoss()
	local s = self.segments[self.first]

	self.health = self.health - 1
	
	if self.health == 0 then
		s.coloreffect = ColorManager.sinCityEffect
		s.size = self.size

		Effect.createEffects(s, 50)
		
		self.health = bossThree.maxHealth
		self.segments[self.first] = nil
		self.first = self.first + 1
		
		if self.first <= self.last then self.position = self.segments[self.first].position end
		
		-- going vulnerable
		self.colors[1]:setAndGo(122, 0, 200)
		self.colors[2]:setAndGo(122, 255, 200)
		self.colors[3]:setAndGo(122, 0, 200)
		self.colors[4]:setAndGo(0, 60, 200)
		
		self.vulnerable = false
		self.colors[1].alsoCall = function() self.vulnerable = true self.colors[1].alsoCall = nil end
	else
		-- damage color
		local d = self.health/bossThree.maxHealth
		self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		--self.colors[3] is already correct
		Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
			self.colors[1]:setAndGo(nil , (1 - d) * 255, 300)
			self.colors[2]:setAndGo(nil, d * 255, 300)
		end
		}
	end
end

function bossThree:yellowGuyHealthLoss()
	self.health = self.health - 1

	local d = self.health/bossThree.yellowGuyHealth

	if self.currentBehavior == bossThree.behaviors.third then
		d = (max(d, .5) - .5) * 2
		--self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		--self.colors[3] is already correct
		Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
			self.colors[2]:setAndGo(nil, d * 255, 300)
		end
		}	
	elseif self.currentBehavior == bossThree.behaviors.fourth then
		d = d * 2
		
		self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		self.colors[3]:setAndGo(nil, 0, 1200)
		
		Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
			self.colors[1]:setAndGo(nil, .94 * 255 + (1 - d) * .06 * 255, 300)
			self.colors[2]:setAndGo(nil, d * .86 * 255, 300)
			self.colors[3]:setAndGo(nil, d * .51 * 255, 300)
		end
		}	
	end
end

function bossThree:pseudoKill()
	self.hide = true
	self.spawnfood:remove()
	Effect.createEffects(self, 200)

	self.yellowGuyTimer:remove()
	self.yellowGuyAngle:remove()

	for i = 1, 4 do
		self.colors[i]:remove()
	end
end

function bossThree:kill()
	Body.kill(self)

	Timer:new{ timeLimit = 0, onceOnly = true, callback = function()
		-- can't call this now or it will fuck things up
		bossThree.food:clear()
		bossThree.ghost:clear()
	end
	}
end

bossThree.food = CircleEffect:new{
	size = 1,
	variance = 4,
	shader = Base.circleShader,
	bodies = Group:new{},
	__type = 'bossThreefood'
}

Body.makeClass(bossThree.food)

function bossThree.food:revive()
	Body.revive(self)

	if bossThree.bodies[1].yellowGuy then
		self.mode = 'fill'
		self.coloreffect = bossThree.bodies[1].yellowGuy.onRage and
			ColorManager.getColorEffect(240, 0, 120, 40) or ColorManager.getColorEffect(255, 255, 255, 40)
	end

	self.growToSize = 25
	self.sizeGrowth = 20
	self.alphaFollows = VarTimer:new{var = 255}
	self.explode = false
	self.eaten = false

	Base.restrainInScreen(self.position)

	return self
end

function bossThree.food:draw()
	CircleEffect.draw(self)
	if self.newSegmentSize then
		graphics.setColor(ColorManager.getComposedColor(self.variance, nil, ColorManager.noLSDEffect))
		graphics.circle('fill', self.position[1], self.position[2], self.newSegmentSize.var)
	end
end

function bossThree.food:update( dt )
	CircleEffect.update(self, dt)

	if not self.eaten then
		Shot.bodies:forEachAlive(function(shot)
			if self:collidesWith(shot) then
				if self.growToSize then -- cancels growth
					self.sizeGrowth = 0
					self.growToSize = nil
				end

				self.size = self.size - 7

				shot.explosionEffect = true
				shot:kill()
				if self.size <= 7 then self.size = 0 self:kill() end
			end
		end)
	end

	local b3 = bossThree.bodies[1] -- the boss
	if self.eaten then
		if not b3.yellowGuy and b3.segments[b3.last].position:distsqr(self.position) < 10 then
			local t = 100/bossThree.baseSpeed
			-- grows a new part for the snake
			self.newSegmentSize = VarTimer:new{}
			self.newSegmentSize:setAndGo(0, b3.size, b3.size/t)

			Timer:new{
				timeLimit = t,
				onceOnly = true,
				running = true,
				callback = function()
					self.sizeGrowth = -70

					self.newSegmentSize:remove()
					self.newSegmentSize = nil

					if b3.yellowGuy then return end
					b3.last = b3.last + 1
					b3.segments[b3.last] = {
						position = self.position:clone(),
						speed = self.setSpeed,
						extraposition = Vector:new{0, 0},
						target = self.setTarget,
						prevdist = self.setPrevdist
					}
				end
			}

			self.update = CircleEffect.update -- no more fancy stuff
		end
	elseif b3.position:distsqr(self.position) < 10 then
			self.eaten = true
		-- 'eat'
		if not b3.yellowGuy then
			self.growToSize = b3.size
			self.sizeGrowth = 100
			local s = b3.segments[b3.first]
			-- new segment will be a clone of the first one
			self.setSpeed = s.speed:clone()
			self.setTarget = s.target
			self.setPrevdist = s.prevdist
		else
			self.update = CircleEffect.update -- no more fancy stuff
			self.sizeGrowth = -100
			self.explode = true
			self.explodeShot = b3.yellowGuy.onRage and Enemies.grayball or Enemies.multiball
			if b3.yellowGuy.onRage then
				-- make yellow yellowGuy invulnerable for some time
				b3.vulnerable = false
				b3.colors[1]:setAndGo(nil, 122, 100)
				b3.colors[2]:setAndGo(nil, 122, 100)
				b3.colors[3]:setAndGo(nil, 122, 100)
				b3.colors[4]:setAndGo(nil, 0, 100)
				Timer:new{
					timeLimit = 2,
					onceOnly = true,
					running = true,
					callback = function ()
						local d = b3.health/bossThree.yellowGuyHealth
						d = d * 2
						b3.colors[1]:setAndGo(nil, .94 * 255 + (1-d) * .06 * 255, 300)
						b3.colors[2]:setAndGo(nil, d * .86 * 255, 300)
						b3.colors[3]:setAndGo(nil, d * .51 * 255, 300)
						b3.colors[4]:setAndGo(nil, 50, 100)
						b3.colors[1].alsoCall = function() b3.colors[1].alsoCall = nil b3.vulnerable = true end
					end
				}
			end
		end
	end
end

function bossThree.food:kill()
	Body.kill(self)

	self.alphaFollows:remove()

	if self.explode then
		local ang = random() * math.pi * 2
		local n = 16
		for i = 1, n do
			local e = self.explodeShot.bodies:getFirstDead():revive()
			e.position:set(self.position)
			e.speed:set(math.cos(ang) * v * 1.5, math.sin(ang) * v * 1.5)
			e:register()
			ang = ang + math.pi * 2 / n
		end
	end
end

bossThree.ghost = Body:new {
	size = 40,
	health = 24,
	bodies = Group:new{},
	shader = Base.circleShader,
	vulnerable = false,
	__type = 'bossThreeghost'
}

Body.makeClass(bossThree.ghost)

function bossThree.ghost:revive()
	Body.revive(self)

	self.shootTimer = Timer:new {
		timeLimit = 2
	}

	function self.shootTimer.callback()
		local e = Enemies.glitchball.bodies:getFirstDead():revive()
		e.position:set(self.position)
		e.speed:set(psycho.position):sub(self.position):normalize():mult(1.5 * v, 1.5 * v)
		e:register()
	end

	self.ring = CircleEffect:new{ size = self.size + 3, alpha = 255, sizeGrowth = 0, lineWidth = 8, position = self.position, coloreffect = ColorManager.noLSDEffect }

	return self
end

function bossThree.ghost:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance, nil, self.coloreffect))
	graphics.circle('fill', self.position[1], self.position[2], self.size)

	self.ring:draw()
end

function bossThree.ghost:update( dt )
	Body.update(self, dt)
	self.ring:update(dt)

	bossFive.bounceInScreen(self)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

	Shot.bodies:forEachAlive(function(shot)
		if self.alive and Base.collides(shot, self.ring) then
			shot.explosionEffect = true
			shot:kill()

			if self.vulnerable and self.health > 0 then
				self.health = self.health - 1
				self.ring.size = (self.health/bossThree.ghost.health) * self.size * 2 + self.size
				if self.health == 0 then self:kill() end
			end
		end
	end)
end

function bossThree.ghost:kill()
	Body.kill(self)
	RecordsManager.addScore(250)

	Effect.createEffects(self, 30)

	self.shootTimer:remove()

	self.ring:kill()

	local anyAlive = false
	bossThree.ghost.bodies:forEachAlive(function(ghost)
		anyAlive = true
		ghost.shootTimer.timeLimit = ghost.shootTimer.timeLimit/1.5
	end)

	if not anyAlive then bossThree.bodies:kill() end
end