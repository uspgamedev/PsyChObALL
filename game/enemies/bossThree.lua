local max, min, abs, random, pairs, unpack, next, ipairs = math.max, math.min, math.abs, math.random, pairs, unpack, next, ipairs

bossThree = Body:new{
	size = 50,
	yellowguysize = 80,
	sizeGrowth = 0,
	basespeed = 1.4*v,
	maxhealth = 13,
	yellowguyhealth = 60,
	vulnerable = true,
	segmentsN = 9,
	shader = Base.circleShader,
	maxsize = width,
	visible = true,
	ord = 6,
	__type = 'bossThree'
}

Body.makeClass(bossThree)

bossThree.behaviors = {}

function bossThree.behaviors.first( self )
	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		if s.target == 5 then 
			s.target = 1
			s.prevdist = width - 120
			s.position:set(60, 60)
			bossThree.goright(s)
		end
	end
	if self.last - self.first < bossThree.segmentsN - 3 and ((self.y > height/2 and self.x < width/4) or (self.y <= height/2 and self.x > 3*width/4))  then
		RecordsManager.addScore(750)
		local t = self.segments[self.first].target
		for i = self.first + 1, self.last, 1 do
			if self.segments[i].target ~= t then return end
		end
		self.shoottimer.timelimit = self.shoottimer.timelimit/1.4
		self.currentBehavior = Base.doNothing
		local s = Base.sign(self.segments[self.first].speed.x)
		local x = self.x + s*2
		local t = self.segments[self.first].target
		for i = t, 4, 1 do self.path[i] = nil end
		self.path[#self.path + 1] = {x, self.y}
		for i = self.first, self.last, 1 do
			local s = self.segments[i]
			s.prevdist = abs(x - s.position.x)
		end
		local y = self.y
		local dir = x > self.x and bossThree.goright or bossThree.goleft
		for i = 1, 10 do
			y = y - 144
			if y < 0 then y = y + height end
			self.path[#self.path + 1] = {x, y, onDeparture = bossThree.goup}
			x = x + s*216
			if x >= width then x = x - width end
			if x < 0 then x = x + width end
			self.path[#self.path + 1] = {x, y, onDeparture = dir}
		end
		self.path[#self.path].onArrival = function(s)
			if s ~= self.segments[self.first] then return end
			local s1 = s
			local foodpos = s1.speed:normalized():mult(width/8, width/8):add(s1.position):set(nil, height/2)
			bossThree.food:new{ position = foodpos }:register()
			self.path[#self.path + 1] = {foodpos.x, self.y}
			self.path[#self.path + 1] = {foodpos.x, foodpos.y}
			self.path[#self.path].onArrival = function ( s )
				self.currentBehavior = bossThree.behaviors.second
			end
			self.currentBehavior = Base.doNothing
			self.spawnfood = Timer:new{
				timelimit = random()*7 + 9,
				running = true,
				funcToCall = function(timer)
					timer.timelimit = random()*7 + 9
					if self.last - self.first + 1 >= 7 then return end
					local pos = self.position + {width/2, width/2}
					pos.x = max(min(pos.x % width, width-100), 100)
					pos.y = max(min(pos.y % height, height-100), 100)
					bossThree.food:new{position = pos}:register()
				end
			}
		end
		self.snakemode = true
	end
end

function bossThree.behaviors.second( self )
	if next(bossThree.food.bodies) then
		local i, v = next(bossThree.food.bodies)
		if not v.eaten then
			self:trytofollow(v.position)
		elseif psycho.canBeHit then self:trytofollow(psycho.position) end
	else
		if psycho.canBeHit then self:trytofollow(psycho.position) end
	end

	if self.first == self.last then
		RecordsManager.addScore(1000)
		self.speedbak = self.speed:clone()
		self.speed:reset()
		Timer:new{
			timelimit = 1.5,
			onceOnly = true,
			running = true,
			funcToCall = function()
				self.speed:set(self.speedbak)
				self.speedbak = nil
				self.health = bossThree.yellowguyhealth
			end
		}
		self.shoottimer:remove()
		self.shoottimer = nil
		self.health =  bossThree.yellowguyhealth
		self.sizeGrowth = 10
		self.colors[1]:setAndGo(nil, 255, 80)
		self.colors[2]:setAndGo(nil, 255, 80)
		self.colors[3]:setAndGo(nil, 0, 80)
		self.path = nil
		self.segments = {self.segments[self.first]}
		self.first, self.last = 1, 1
		self.guy = self.segments[1]
		self.position = self.guy.position
		self.speed = self.guy.speed
		self.trytofollow = self.yellowguytrytofollow
		self.handleHealthLoss = bossThree.yellowguyHealthLoss
		Base.clearTable(bossThree.food.bodies)
		do
			self.guyangle = VarTimer:new{var = self.Vx > 0 and 0 or self.Vx < 0 and math.pi or self.Vy > 0 and math.pi/2 or 3*math.pi/2}
			self.guyangle.pausable = true
			local ang = 0
			self.yellowguytimer = Timer:new{
				running = true,
				timelimit = nil,
				timecount = 0,
				increasing = true,
				limit = .1,
				change = Base.toRadians(20),
				pause = false,
				funcToCall = function(t, dt)
					t.timecount = t.timecount + dt
					if t.timecount > t.limit then 
						if t.pause then t:stop() t.alsoCall() return end
						t.timecount = 0 
						t.increasing = not t.increasing 
					end
					ang = (t.increasing and t.timecount or t.limit - t.timecount)*t.change/t.limit
				end
			}
			self.invertedstencil = function() graphics.arc('fill', self.x, self.y, self.size, self.guyangle.var - ang, self.guyangle.var + ang) end
		end

		local cs = {{255, 0, 0},{255,255,255},{230, 143, 172}, {205, 140, 0}}
		for _, color in ipairs(cs) do
			local g = bossThree.ghost:new{}
			g:register()
			Enemy.__init(g)
			g.speed:set(Base.sign(random()-.5)*random(v*.7, v), Base.sign(random()-.5)*random(v*.7, v))
			g.coloreffect = ColorManager.getColorEffect(unpack(color))
		end
		
		self.currentBehavior = bossThree.behaviors.third
	end
end

function bossThree.behaviors.third( self )
	if next(bossThree.food.bodies) then
		local i, v = next(bossThree.food.bodies)
		if not v.eaten then
			self:trytofollow(v.position)
		elseif psycho.canBeHit then self:trytofollow(psycho.position) end
	else
		if psycho.canBeHit then self:trytofollow(psycho.position) end
	end

	if self.health/bossThree.yellowguyhealth < .5 then
		RecordsManager.addScore(1000)
		self.speedbak = self.speed:clone()
		self.speed:reset()
		self.currentBehavior = Base.doNothing
		self.vulnerable = false
		Timer:new{ timelimit = 1, running = true, onceOnly = true, funcToCall = function()
				Base.clearTable(bossThree.food.bodies)
				local t = self.yellowguytimer
				t.increasing = true
				t.limit = 1
				t.change = 3*math.pi/4
				t.pause = true
				t.timecount = 0
				t.alsoCall = function()
					t:start()
					t.timecount = 0
					t.pause = true
					t.increasing = false
					self.colors[1]:setAndGo(nil, .94*255, 40)
					self.colors[2]:setAndGo(nil, .86*255, 40)
					self.colors[3]:setAndGo(nil, .51*255, 40)
					t.alsoCall = function()
						t:start()
						t.timecount = 0
						t.pause = false
						t.increasing = true
						t.limit = .1
						t.change = Base.toRadians(20)
						t.alsoCall = nil
						self.currentBehavior = bossThree.behaviors.fourth
						self.vulnerable = true
						self.guy.onRage = true
						self.speed:set(self.speedbak)
						self.speedbak = nil
						self.health = bossThree.yellowguyhealth*.5
						self.spawnfood.time = self.spawnfood.timelimit
					end
				end
			end
		}
	end
end

function bossThree.behaviors.fourth( self )
	if next(bossThree.food.bodies) then
		local i, v = next(bossThree.food.bodies)
		if not v.eaten then
			self:trytofollow(v.position)
		elseif psycho.canBeHit then self:trytofollow(psycho.position) end
	else
		if psycho.canBeHit then self:trytofollow(psycho.position) end
	end

	if self.health == 0 then
		RecordsManager.addScore(1500)
		self.speed:reset()
		self.currentBehavior = Base.doNothing
		self.vulnerable = false
		Timer:new{ timelimit = 1, running = true, onceOnly = true, funcToCall = function()
				Base.clearTable(bossThree.food.bodies)
				local t = self.yellowguytimer
				t.increasing = true
				t.limit = 1
				t.change = math.pi
				t.pause = true
				t.timecount = 0
				t.alsoCall = function() 
					self.delete = true
					for _, g in pairs(bossThree.bodies) do
						if g.__type == 'bossThreeghost' then
							g.ring.sizeGrowth = 30
							g.ring.desiredsize = g.size*3
						end
					end
					Timer:new{
						running = true,
						onceOnly = true,
						timelimit = 2,
						funcToCall = function()
							local change = VarTimer:new{var = 0}
							local c = ColorManager.getColorEffect({var = 122}, {var = 122}, {var = 122}, change)
							change:setAndGo(0, 255, 80)
							for _, g in pairs(bossThree.bodies) do
								if g.__type == 'bossThreeghost' then
									g.ring.coloreffect = c
									g.vulnerable = true
									g.shoottimer:start()
								end
							end
						end
					}
				end
			end
		}
	end
end

function bossThree:defaulttrytofollow( pos )
	local s1 = self.segments[self.first]
	if s1.target <= #self.path then return end
	if s1.speed.x ~= 0 then
		if abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			local gd, gu = bossThree.godown, bossThree.goup
			local newf = dist > 0 and (dist > height/2 and gu or gd) or (dist < -height/2 and gd or gu)
			local curf = s1.speed.x > 0 and bossThree.goright or bossThree.goleft
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
			local gr, gl = bossThree.goright, bossThree.goleft
			local newf = dist > 0 and (dist > width/2 and gl or gr) or (dist < -width/2 and gr or gl)
			local curf = s1.speed.y > 0 and bossThree.godown or bossThree.goup
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

function  bossThree:yellowguytrytofollow( pos )
	if self.Vx ~= 0 then
		if abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			if (dist > 0 and dist < height/2) or (dist < 0 and dist < -height/2) then
				self.speed:set(0, bossThree.basespeed)
				self.guyangle:setAndGo(nil, Base.toRadians(90), Base.toRadians(100))
			else
				self.guyangle.var = self.Vx > 0 and Base.toRadians(360) or Base.toRadians(180)
				self.guyangle:setAndGo(nil, Base.toRadians(270), Base.toRadians(100))
				self.speed:set(0, -bossThree.basespeed)
			end
		end
	else
		if abs(pos.y - self.y) < 9 then
			local dist = pos.x - self.x
			if (dist > 0 and dist < width/2) or (dist < 0 and dist < -width/2) then
					self.guyangle.var = self.Vy > 0 and Base.toRadians(90) or Base.toRadians(-90)
					self.guyangle:setAndGo(nil, Base.toRadians(0), Base.toRadians(100))
					self.speed:set(bossThree.basespeed, 0)
				else
					self.speed:set(-bossThree.basespeed, 0)
					self.guyangle:setAndGo(nil, Base.toRadians(180), Base.toRadians(100))
			end
		end
	end
end

function bossThree.setspeed( speed )
	return function(s) s.speed:set(speed) end
end

bossThree.godown = bossThree.setspeed {0, bossThree.basespeed}
bossThree.goleft = bossThree.setspeed {-bossThree.basespeed, 0}
bossThree.goright = bossThree.setspeed {bossThree.basespeed, 0}
bossThree.goup = bossThree.setspeed {0, -bossThree.basespeed}

function bossThree:draw()
	if not self.visible then return end
	if not Cheats.image.enabled then graphics.setPixelEffect(Base.circleShader) end

	if self.first <= self.last then
		local s = self.segments[self.first]
		graphics.setColor(ColorManager.getComposedColor(self.variance, nil, self.coloreffect))
		if self.guy then
			graphics.setPixelEffect()
			graphics.setInvertedStencil(self.invertedstencil)
			love.graphics.circle(self.mode, s.position[1]*ratio, s.position[2]*ratio, self.size*ratio)
		else
			graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		end

		graphics.translate(unpack(s.extraposition))

		if self.guy then 
			graphics.setInvertedStencil(self.invertedstencil)
			love.graphics.circle(self.mode, s.position[1]*ratio, s.position[2]*ratio, self.size*ratio)
		else
			graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		end

		graphics.translate(-s.extraposition[1], -s.extraposition[2])
		
		if self.guy then 
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
	graphics.setPixelEffect()
end

local auxVec = Vector:new{}

function bossThree:update( dt )
	if not self.visible then return end
	self:currentBehavior()
	CircleEffect.update(self, dt)

	if self.size > self.yellowguysize then
		self.size = self.yellowguysize
		self.sizeGrowth = 0
	end

	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		s.position:add(auxVec:set(s.speed):mult(dt))
		for _, v in pairs(Shot.bodies) do
			if Base.collides(s.position, self.size, v.position, v.size) then
				v.collides = true
				v.explosionEffect = true
				if i == self.first and self.health > 0 and self.vulnerable then 
					self:handleHealthLoss()
				end
			end
		end

		if psycho.canBeHit and not DeathManager.gameLost and Base.collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.diereason = "shot"
			DeathManager.manageDeath()
		end

		if self.snakemode then
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
				s.position:set(p)
				if p.onArrival then p.onArrival(s) end
				s.target = s.target + 1
				if s.target > #self.path then 
				else 
					p = self.path[s.target]
					s.prevdist = s.position:distsqr(p)
					if p.onDeparture then p.onDeparture(s)
					else s.speed:set(p):sub(s.position):normalize():mult(bossThree.basespeed) end
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
		self.health = bossThree.maxhealth
		self.segments[self.first] = nil
		self.first = self.first + 1
		if self.first <= self.last then self.position = self.segments[self.first].position end
		self.colors[1]:setAndGo(122, 0, 60)
		self.colors[2]:setAndGo(122, 255, 60)
		self.colors[3]:setAndGo(122, 0, 60)
		self.colors[4]:setAndGo(0, 60, 60)
		self.vulnerable = false
		self.colors[1].alsoCall = function() self.vulnerable = true self.colors[1].alsoCall = nil end
	else
		local d = self.health/bossThree.maxhealth
		self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		--self.colors[3] is already correct
		Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
			self.colors[1]:setAndGo(nil , (1-d)*255, 300)
			self.colors[2]:setAndGo(nil, d*255, 300)
		end
		}
	end
end

function bossThree:yellowguyHealthLoss()
	self.health = self.health - 1
	local d = self.health/bossThree.yellowguyhealth
	if self.currentBehavior == bossThree.behaviors.third then
		d = (max(d, .5) - .5)*2
		--self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		--self.colors[3] is already correct
		Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
			self.colors[2]:setAndGo(nil, d*255, 300)
		end
		}	
	elseif self.currentBehavior == bossThree.behaviors.fourth then
		d = d*2
		self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		self.colors[3]:setAndGo(nil, 0, 1200)
		Timer:new{timelimit = .05, onceOnly = true, running = true, funcToCall = function()
			self.colors[1]:setAndGo(nil, .94*255 + (1-d)*.06*255, 300)
			self.colors[2]:setAndGo(nil, d*.86*255, 300)
			self.colors[3]:setAndGo(nil, d*.51*255, 300)
		end
		}	
	end
end

function bossThree:__init()
	paintables.food = bossThree.food
	paintables.ghosts = bossThree.ghost
	self.trytofollow = self.defaulttrytofollow
	self.handleHealthLoss = self.defaultHealthLoss

	local n = self.segmentsN
	self.position = Vector:new{-60, 60}
	self.path = {{width - 60, 60}, {width - 60, height - 60}, {60, height - 60}, {60, 60}}
	self.segments = {}
	self.speedvalue = spd
	self.colors = {VarTimer:new{var = 0}, VarTimer:new{var = 255}, VarTimer:new{var = 0}, VarTimer:new{var = 70}, VarTimer:new{var = 50}}
	self.coloreffect = ColorManager.getColorEffect(unpack(self.colors))
	local speed = Vector:new(Base.clone(self.path[1])):sub(self.position):normalize()
	local diff = speed * (self.size*2)
	speed:mult(bossThree.basespeed)
	self.speed = speed:clone()
	self.health = bossThree.maxhealth
	self.first, self.last = 1, n
	self.segments[1] = { speed = speed, position = self.position, extraposition = Vector:new{0,0}, prevdist = self.position:distsqr(self.path[1]), target = 1 }
	self.currentBehavior = bossThree.behaviors.first
	for i = 2, n, 1 do
		local s = {}
		s.speed = speed:clone()
		s.position = self.position - ((i - 1)*diff)
		s.prevdist = s.position:distsqr(self.path[1])
		s.target = 1
		s.extraposition = Vector:new{0, 0}
		self.segments[i] = s
	end
	self.fixtimer = Timer:new{ --gambiarra (arruma os segmentos da snake se necessário)
		timelimit = .1,
		running = true,
		funcToCall = function()
			local prev = nil
			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if prev and prev.target == s.target and abs(prev.position:distsqr(s.position) - 10000) < 100000 then
					s.position:set(prev.position):sub(prev.speed:normalized():mult(100,100))
				end
				prev = s
			end
		end
	}
	self.shoottimer = Timer:new{
		timelimit = .8,
		running = true,
		time = -3
	}

	function self.shoottimer.funcToCall()
		if not psycho.canBeHit then return end
		local e = Enemies.grayball:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():add(random()/10, random()/10):normalize():mult(2 * v, 2 * v)
		e:register()
	end
end

function bossThree:handleDelete()
	Base.clearTable(bossThree.food.bodies)
	Base.clearTable(bossThree.ghost.bodies)
	paintables.food = nil
	paintables.ghosts = nil
	self.spawnfood:remove()
	self.yellowguytimer:remove()
	Effect.createEffects(self, 200)
end

bossThree.food = CircleEffect:new{
	size = 1,
	sizeGrowth = 20,
	variance = 4,
	shader = Base.circleShader,
	bodies = {},
	index = false,
	__type = 'bossThreefood'
}

Body.makeClass(bossThree.food)

function bossThree.food:__init()
	if bossThree.bodies[1].guy then
		self.mode = 'fill'
		self.coloreffect = bossThree.bodies[1].guy.onRage and
			ColorManager.getColorEffect(240, 0, 120, 40) or ColorManager.getColorEffect(255, 255, 255, 40)
	end

	self.normalsize = 25
	self.creationsize = VarTimer:new{var = 0}
	self.alphaFollows = VarTimer:new{var = 255}
	Base.restrainInScreen(self.position)
end

function bossThree.food:draw()
	CircleEffect.draw(self)
	if self.creationsize.var > 0 then
		graphics.setColor(ColorManager.getComposedColor(self.variance, nil, ColorManager.noLSDEffect))
		graphics.circle('fill', self.position[1], self.position[2], self.creationsize.var)
	end
end

function bossThree.food:update( dt )
	CircleEffect.update(self, dt)

	if not self.eaten then
		for _, s in pairs(Shot.bodies) do
			if self:collidesWith(s) then
				if self.normalsize then
					self.sizeGrowth = 0
					self.normalsize = nil
				else
					self.size = self.size - 5
				end
				s.collides = true
				s.explosionEffect = true
				if self.size <= 5 then self.size = 0 self.delete = true return end
			end
		end
	end

	if self.normalsize and self.size > self.normalsize then
		self.size = self.normalsize
		self.normalsize = nil
		self.sizeGrowth = 0
	end

	local b3 = bossThree.bodies[1]
	if self.eaten then
		if not b3.guy and b3.segments[b3.last].position:distsqr(self.position) < 10 then
			local t = 100/bossThree.basespeed
			self.creationsize:setAndGo(0, b3.size, b3.size/t)
			Timer:new{
				timelimit = t,
				onceOnly = true,
				running = true,
				funcToCall = function()
					self.sizeGrowth = -70
					self.creationsize.var = 0
					if b3.guy then return end
					b3.last = b3.last + 1
					b3.segments[b3.last] = {
						position = self.position:clone(),
						speed = self.speedtoset,
						extraposition = Vector:new{0, 0},
						target = self.targettoset,
						prevdist = self.prevdisttoset
					}
				end
			}
			self.update = CircleEffect.update
		end
	elseif b3.position:distsqr(self.position) < 10 then
		if not b3.guy then
			self.normalsize = b3.size
			self.sizeGrowth = 100
			self.eaten = true
			local s = b3.segments[b3.first]
			self.speedtoset = s.speed:clone()
			self.targettoset = s.target
			self.prevdisttoset = s.prevdist
		else
			self.sizeGrowth = -100
			self.update = CircleEffect.update
			self.explode = true
			self.explodeShot = b3.guy.onRage and Enemies.grayball or Enemies.multiball
			if b3.guy.onRage then
				b3.vulnerable = false
				b3.colors[1]:setAndGo(nil, 122, 100)
				b3.colors[2]:setAndGo(nil, 122, 100)
				b3.colors[3]:setAndGo(nil, 122, 100)
				b3.colors[4]:setAndGo(nil, 0, 100)
				Timer:new{
					timelimit = 2,
					onceOnly = true,
					running = true,
					funcToCall = function ()
						local d = b3.health/bossThree.yellowguyhealth
						d = d*2
						b3.colors[1]:setAndGo(nil, .94*255 + (1-d)*.06*255, 300)
						b3.colors[2]:setAndGo(nil, d*.86*255, 300)
						b3.colors[3]:setAndGo(nil, d*.51*255, 300)
						b3.colors[4]:setAndGo(nil, 50, 100)
						b3.colors[1].alsoCall = function() b3.colors[1].alsoCall = nil b3.vulnerable = true end
					end
				}
			end
			self.eaten = true
		end
	end
end

function bossThree.food:handleDelete()
	if self.explode then
		local ang = random() * math.pi * 2
		local n = 16
		for i = 1, n do
			local e = self.explodeShot:new{}
			e.position:set(self.position)
			e.speed:set(math.cos(ang)*v*1.5, math.sin(ang)*v*1.5)
			e:register()
			ang = ang + math.pi*2/n
		end
	end
end

bossThree.ghost = Body:new {
	size = 40,
	health = 24,
	bodies = {},
	shader = Base.circleShader,
	vulnerable = false,
	__type = 'bossThreeghost'
}

Body.makeClass(bossThree.ghost)

function bossThree.ghost:__init()
	self.ring = CircleEffect:new{
		size = self.size + 5,
		alpha = 255,
		coloreffect = ColorManager.noLSDEffect,
		sizeGrowth = 0,
		variance = self.variance,
		position = self.position,
		linewidth = 7
	}
	self.shoottimer = Timer:new {
		timelimit = 2
	}
	function self.shoottimer.funcToCall()
		local e = Enemies.glitchball:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():add(random()/10, random()/10):normalize():mult(1.5 * v, 1.5 * v)
		e:register()
	end
end

function bossThree.ghost:draw()
	graphics.setColor(ColorManager.getComposedColor(self.variance, nil, self.coloreffect))
	graphics.circle('fill', self.position[1], self.position[2], self.size)
end

function bossThree.ghost:update( dt )
	Body.update(self, dt)
	if self.x  + self.size > width then self.speed:set(-abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  abs(self.Vy)) end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end

	for _, s in pairs(Shot.bodies) do
		if self.ring:collidesWith(s) then
			s.collides = true
			s.explosionEffect = true
			if self.vulnerable and self.health > 0 then
				self.health = self.health - 1
				self.ring.size = (self.health/bossThree.ghost.health)*self.size*2 + self.size
				if self.health == 0 then self.delete = true end
			end
		end
	end
end

function bossThree.ghost:handleDelete()
	RecordsManager.addScore(250)
	Effect.createEffects(self, 30)
	self.ring.delete = true
	self.shoottimer:remove()
	for _, g in pairs(bossThree.bodies) do
		g.shoottimer.timelimit = g.shoottimer.timelimit/1.9
	end
end