bossThree = body:new{
	size = 50,
	yellowguysize = 80,
	sizeGrowth = 0,
	basespeed = 1.4*v,
	maxhealth = 13,
	yellowguyhealth = 60,
	vulnerable = true,
	segmentsN = 9,
	maxsize = width,
	visible = true,
	ord = 6,
	__type = 'bossThree'
}

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
		addscore(750)
		local t = self.segments[self.first].target
		for i = self.first + 1, self.last, 1 do
			if self.segments[i].target ~= t then return end
		end
		self.shoottimer.timelimit = self.shoottimer.timelimit/1.4
		self.currentBehavior = donothing
		local s = sign(self.segments[self.first].speed.x)
		local x = self.x + s*2
		local t = self.segments[self.first].target
		for i = t, 4, 1 do self.path[i] = nil end
		table.insert(self.path, {x, self.y})
		for i = self.first, self.last, 1 do
			local s = self.segments[i]
			s.prevdist = math.abs(x - s.position.x)
		end
		local y = self.y
		local dir = x > self.x and bossThree.goright or bossThree.goleft
		for i = 1, 10 do
			y = y - 144
			if y < 0 then y = y + height end
			table.insert(self.path, {x, y, onDeparture = bossThree.goup})
			x = x + s*216
			if x >= width then x = x - width end
			if x < 0 then x = x + width end
			table.insert(self.path, {x, y, onDeparture = dir})
		end
		self.path[#self.path].onArrival = function(s)
			if s ~= self.segments[self.first] then return end
			local s1 = s
			local foodpos = s1.speed:normalized():mult(width/8, width/8):add(s1.position):set(nil, height/2)
			bossThree.food:new{ position = foodpos }:register()
			table.insert(self.path, {foodpos.x, self.y})
			table.insert(self.path, {foodpos.x, foodpos.y})
			self.path[#self.path].onArrival = function ( s )
				self.currentBehavior = bossThree.behaviors.second
			end
			self.currentBehavior = donothing
			self.spawnfood = timer:new{
				timelimit = math.random()*7 + 9,
				running = true,
				funcToCall = function(timer)
					timer.timelimit = math.random()*7 + 9
					if #self.segments >= 7 then return end
					local pos = self.position + {math.random(width/4, 3*width/4), math.random(height/4, 3*height/4)}
					pos.x = math.max(math.min(pos.x % width, width-100), 100)
					pos.y = math.max(math.min(pos.y % height, height-100), 100)
					bossThree.food:new{position = pos}:register()
				end
			}
		end
		self.snakemode = true
	end
end

function bossThree.behaviors.second( self )
	if next(paintables.food) then
		local i, v = next(paintables.food)
		if not v.eaten then
			self:trytofollow(v)
		elseif psycho.canbehit then self:trytofollow(psycho) end
	else
		if psycho.canbehit then self:trytofollow(psycho) end
	end

	if self.first == self.last then
		addscore(1000)
		self.speedbak = self.speed:clone()
		self.speed:reset()
		timer:new{
			timelimit = 1.5,
			onceonly = true,
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
		cleartable(bossThree.food.bodies)
		do
			self.guyangle = vartimer:new{var = self.Vx > 0 and 0 or self.Vx < 0 and math.pi or self.Vy > 0 and math.pi/2 or 3*math.pi/2}
			self.guyangle.pausable = true
			local ang = 0
			self.yellowguytimer = timer:new{
				running = true,
				timelimit = nil,
				timecount = 0,
				increasing = true,
				limit = .1,
				change = torad(20),
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
			enemy.__init(g)
			g.speed:set(sign(math.random()-.5)*math.random(v*.7, v), sign(math.random()-.5)*math.random(v*.7, v))
			g.coloreffect = getColorEffect(unpack(color))
			table.insert(bossThree.bodies, g)
		end
		
		self.currentBehavior = bossThree.behaviors.third
	end
end

function bossThree.behaviors.third( self )
	if next(paintables.food) then
		local i, v = next(paintables.food)
		if not v.eaten then
			self:trytofollow(v)
		elseif psycho.canbehit then self:trytofollow(psycho) end
	else
		if psycho.canbehit then self:trytofollow(psycho) end
	end
	if self.health/bossThree.yellowguyhealth < .5 then
		addscore(1000)
		self.speedbak = self.speed:clone()
		self.speed:reset()
		self.currentBehavior = donothing
		self.vulnerable = false
		timer:new{ timelimit = 1, running = true, onceonly = true, funcToCall = function()
				cleartable(bossThree.food.bodies)
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
						t.change = torad(20)
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
	if next(paintables.food) then
		local i, v = next(paintables.food)
		if not v.eaten then
			self:trytofollow(v)
		elseif psycho.canbehit then self:trytofollow(psycho) end
	else
		if psycho.canbehit then self:trytofollow(psycho) end
	end

	if self.health == 0 then
		addscore(1500)
		self.speed:reset()
		self.currentBehavior = donothing
		self.vulnerable = false
		timer:new{ timelimit = 1, running = true, onceonly = true, funcToCall = function()
				cleartable(bossThree.food.bodies)
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
					timer:new{
						running = true,
						onceonly = true,
						timelimit = 2,
						funcToCall = function()
							local change = vartimer:new{var = 0}
							local c = getColorEffect({var = 122}, {var = 122}, {var = 122}, change)
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
		if math.abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			local gd, gu = bossThree.godown, bossThree.goup
			local newf = dist > 0 and (dist > height/2 and gu or gd) or (dist < -height/2 and gd or gu)
			local curf = s1.speed.x > 0 and bossThree.goright or bossThree.goleft
			local p = {s1.position:unpack()}
			p.onDeparture = curf
			p[1] = p[1] + sign(s1.speed.x)
			self.path[s1.target + 1] = {p[1], pos.y, onDeparture = newf}
			self.path[s1.target] = p

			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if s.target == s1.target then
					s.prevdist = math.abs(s.position[1] - p[1])
				end
			end
		end
	else
		if math.abs(pos.y - self.y) < 9 then
			local dist = pos.x - self.x
			local gr, gl = bossThree.goright, bossThree.goleft
			local newf = dist > 0 and (dist > width/2 and gl or gr) or (dist < -width/2 and gr or gl)
			local curf = s1.speed.y > 0 and bossThree.godown or bossThree.goup
			local p = {s1.position:unpack()}
			p.onDeparture = curf
			p[2] = p[2] + sign(s1.speed.x)
			self.path[s1.target + 1] = {pos.x, p[2], onDeparture = newf}
			self.path[s1.target] = p

			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if s.target == s1.target then
					s.prevdist = math.abs(s.position[2] - p[2])
				end
			end
		end
	end
end

function  bossThree:yellowguytrytofollow( pos )
	if self.Vx ~= 0 then
		if math.abs(pos.x - self.x) < 9 then
			local dist = pos.y - self.y
			if (dist > 0 and dist < height/2) or (dist < 0 and dist < -height/2) then
				self.speed:set(0, bossThree.basespeed)
				self.guyangle:setAndGo(nil, torad(90), torad(100))
			else
				self.guyangle.var = self.Vx > 0 and torad(360) or torad(180)
				self.guyangle:setAndGo(nil, torad(270), torad(100))
				self.speed:set(0, -bossThree.basespeed)
			end
		end
	else
		if math.abs(pos.y - self.y) < 9 then
			local dist = pos.x - self.x
			if (dist > 0 and dist < width/2) or (dist < 0 and dist < -width/2) then
					self.guyangle.var = self.Vy > 0 and torad(90) or torad(-90)
					self.guyangle:setAndGo(nil, torad(0), torad(100))
					self.speed:set(bossThree.basespeed, 0)
				else
					self.speed:set(-bossThree.basespeed, 0)
					self.guyangle:setAndGo(nil, torad(180), torad(100))
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
	--[[if not psycho.extraposition:equals(0, 0) then
		psycho.position:add(psycho.extraposition)
		psycho.size = psycho.size + psycho.sizediff
		body.draw(psycho)
		psycho.position:sub(psycho.extraposition)
		psycho.size = psycho.size - psycho.sizediff
	end]]
	if not self.visible then return end
	if self.first <= self.last then
		local s = self.segments[self.first]
		graphics.setColor(color(colortimer.time + self.variance, nil, self.coloreffect))
		if self.guy then 
			graphics.setInvertedStencil(self.invertedstencil)
		end
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.translate(unpack(s.extraposition))
		if self.guy then graphics.setInvertedStencil(self.invertedstencil) end
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.translate(-s.extraposition[1], -s.extraposition[2])
		if self.guy then 
			graphics.setInvertedStencil()
		end
	end
	for i = self.first + 1, self.last, 1 do
		local s = self.segments[i]
		graphics.setColor(color(colortimer.time + self.variance, nil, noLSDeffect))
		graphics.circle(self.mode, s.position[1], s.position[2], self.size)
		graphics.circle(self.mode, s.position[1] + s.extraposition[1], s.position[2] + s.extraposition[2], self.size)
	end
end

function bossThree:update( dt )
	if not self.visible then return end
	self:currentBehavior()
	circleEffect.update(self, dt)

	if self.size > self.yellowguysize then
		self.size = self.yellowguysize
		self.sizeGrowth = 0
	end

	for i = self.first, self.last, 1 do
		local s = self.segments[i]
		s.position:add(s.speed*dt)
		for _, v in pairs(shot.bodies) do
			if collides(s.position, self.size, v.position, v.size) then
				v.collides = true
				v.explosionEffect = true
				if i == self.first and self.health > 0 and self.vulnerable then 
					self:handleHealthLoss()
				end
			end
		end

		if psycho.canbehit and not gamelost and collides(s.position, self.size, psycho.position, psycho.size) then
			psycho.diereason = "shot"
			lostgame()
		end

		if self.snakemode then
			if s.position[1] < self.size or s.position[1] > width - self.size then
				if s.position[1] < -3 or s.position[1] > width + 3 then
					s.position[1] = s.position[1] + (s.position[1] < width/2 and width or -width)
					s.extraposition:set(s.position[1] < width/2 and width or -width, nil)
				else
					s.extraposition:set(s.position[1] < width/2 and width or -width, nil)
				end
			else
				s.extraposition:set(0, nil)
			end
			if s.position[2] < self.size or s.position[2] > height - self.size then
				if s.position[2] < -3 or s.position[2] > height + 3 then
					s.position[2] = s.position[2] + (s.position[2] < height/2 and height or -height)
					s.extraposition:set(nil, s.position[2] < height/2 and height or -height)
				else
					s.extraposition:set(nil, s.position[2] < height/2 and height or -height)
				end
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

	--[[if self.snakemode then
		if psycho.x < psycho.size or psycho.x > width - psycho.size then
			if psycho.x < 0 or psycho.x > width then
				psycho.x = psycho.x + (psycho.x < width/2 and width or -width)
				psycho.extraposition:set(psycho.x < width/2 and width or -width, nil)
			else
				psycho.extraposition:set(psycho.x < width/2 and width or -width, nil)
			end
		else
			psycho.extraposition:set(0, nil)
		end
		if psycho.y < psycho.size or psycho.y > height - psycho.size then
			if psycho.y < 0 or psycho.y > height then
				psycho.y = psycho.y + (psycho.y < height/2 and height or -height)
				psycho.extraposition:set(nil, psycho.y < height/2 and height or -height)
			else
				psycho.extraposition:set(nil, psycho.y < height/2 and height or -height)
			end
		else
			psycho.extraposition:set(nil, 0)
		end
	end]]
end

function bossThree:defaultHealthLoss()
	local s = self.segments[self.first]
	self.health = self.health - 1
	if self.health == 0 then
		s.coloreffect = sincityeffect
		s.size = self.size
		neweffects(s, 50)
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
		timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
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
		d = (math.max(d, .5) - .5)*2
		--self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		--self.colors[3] is already correct
		timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
			self.colors[2]:setAndGo(nil, d*255, 300)
		end
		}	
	elseif self.currentBehavior == bossThree.behaviors.fourth then
		d = d*2
		self.colors[1]:setAndGo(nil, 255, 1200)
		self.colors[2]:setAndGo(nil, 0, 1200)
		self.colors[3]:setAndGo(nil, 0, 1200)
		timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
			self.colors[1]:setAndGo(nil, .94*255 + (1-d)*.06*255, 300)
			self.colors[2]:setAndGo(nil, d*.86*255, 300)
			self.colors[3]:setAndGo(nil, d*.51*255, 300)
		end
		}	
	end
end

function bossThree:__init()
	paintables.food = bossThree.food.bodies
	self.trytofollow = self.defaulttrytofollow
	self.handleHealthLoss = self.defaultHealthLoss
	--psycho.extraposition = vector:new{0,0}
	local n = self.segmentsN
	self.position = vector:new{-60, 60}
	self.path = {{width - 60, 60}, {width - 60, height - 60}, {60, height - 60}, {60, 60}}
	self.segments = {}
	self.speedvalue = spd
	self.colors = {vartimer:new{var = 0}, vartimer:new{var = 255}, vartimer:new{var = 0}, vartimer:new{var = 70}, vartimer:new{var = 50}}
	self.coloreffect = getColorEffect(unpack(self.colors))
	local speed = vector:new(clone(self.path[1])):sub(self.position):normalize()
	local diff = speed * (self.size*2)
	speed:mult(bossThree.basespeed)
	self.speed = speed:clone()
	self.health = bossThree.maxhealth
	self.first, self.last = 1, n
	self.segments[1] = { speed = speed, position = self.position, extraposition = vector:new{0,0}, prevdist = self.position:distsqr(self.path[1]), target = 1 }
	self.currentBehavior = bossThree.behaviors.first
	for i = 2, n, 1 do
		local s = {}
		s.speed = speed:clone()
		s.position = self.position - ((i - 1)*diff)
		s.prevdist = s.position:distsqr(self.path[1])
		s.target = 1
		s.extraposition = vector:new{0, 0}
		self.segments[i] = s
	end
	self.fixtimer = timer:new{ --gambiarra (arruma os segmentos da snake se necessário)
		timelimit = .1,
		running = true,
		funcToCall = function()
			local prev = nil
			for i = self.first, self.last, 1 do
				local s = self.segments[i]
				if prev and prev.target == s.target and prev.position:distsqr(s.position) ~= 10000 then
					s.position:set(prev.position):sub(prev.speed:normalized():mult(100,100))
				end
				prev = s
			end
		end
	}
	self.shoottimer = timer:new{
		timelimit = .8,
		running = true,
		time = -3
	}

	function self.shoottimer.funcToCall()
		local e = enemies.grayball:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():add(math.random()/10, math.random()/10):normalize():mult(2 * v, 2 * v)
		e:register()
	end
end

function bossThree:handleDelete()
	cleartable(bossThree.food.bodies)
	paintables.food = nil
	self.spawnfood:remove()
	self.yellowguytimer:remove()
	neweffects(self, 200)
end

bossThree.food = circleEffect:new{
	size = 1,
	sizeGrowth = 20,
	variance = 4,
	bodies = {},
	index = false,
	__type = 'bossThreefood'
}

function bossThree.food:__init()
	if bossThree.bodies[1].guy then
		self.mode = 'fill'
		self.coloreffect = bossThree.bodies[1].guy.onRage and
			getColorEffect(240, 0, 120, 40) or getColorEffect(255, 255, 255, 40)
	end

	self.normalsize = 25
	self.creationsize = vartimer:new{var = 0}
	self.alphafollows = vartimer:new{var = 255}
	restrainInScreen(self.position)
end

function bossThree.food:draw()
	circleEffect.draw(self)
	if self.creationsize.var > 0 then
		graphics.setColor(color(colortimer.time + self.variance, nil, noLSDeffect))
		graphics.circle('fill', self.x, self.y, self.creationsize.var)
	end
end

function bossThree.food:update( dt )
	circleEffect.update(self, dt)

	if not self.eaten then
		for _, s in pairs(shot.bodies) do
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
			timer:new{
				timelimit = t,
				onceonly = true,
				running = true,
				funcToCall = function()
					b3.last = b3.last + 1
					b3.segments[b3.last] = {
						position = self.position:clone(),
						speed = self.speedtoset,
						extraposition = vector:new{0, 0},
						target = self.targettoset,
						prevdist = self.prevdisttoset
					}
					self.sizeGrowth = -70
					self.draw = circleEffect.draw
				end
			}
			self.update = circleEffect.update
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
			self.update = circleEffect.update
			self.explode = true
			self.explodeShot = b3.guy.onRage and enemies.grayball or enemies.multiball
			if b3.guy.onRage then
				b3.vulnerable = false
				b3.colors[1]:setAndGo(nil, 122, 100)
				b3.colors[2]:setAndGo(nil, 122, 100)
				b3.colors[3]:setAndGo(nil, 122, 100)
				b3.colors[4]:setAndGo(nil, 0, 100)
				timer:new{
					timelimit = 2,
					onceonly = true,
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
		local ang = math.random() * math.pi * 2
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

bossThree.ghost = body:new {
	size = 40,
	health = 24,
	vulnerable = false,
	__type = 'bossThreeghost'
}

function bossThree.ghost:__init()
	self.ring = circleEffect:new{
		size = self.size,
		alpha = 255,
		coloreffect = noLSDeffect,
		sizeGrowth = 0,
		variance = self.variance,
		position = self.position,
		linewidth = 7
	}
	self.shoottimer = timer:new {
		timelimit = 2
	}
	function self.shoottimer.funcToCall()
		local e = enemies.grayball:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():add(math.random()/10, math.random()/10):normalize():mult(1.5 * v, 1.5 * v)
		e:register()
	end
end

function bossThree.ghost:draw()
	body.draw(self)
end

function bossThree.ghost:update( dt )
	body.update(self, dt)
	if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	for _, s in pairs(shot.bodies) do
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
	addscore(250)
	neweffects(self, 30)
	self.ring.delete = true
	self.shoottimer:remove()
	for _, g in pairs(bossThree.bodies) do
		g.shoottimer.timelimit = g.shoottimer.timelimit/1.9
	end
end