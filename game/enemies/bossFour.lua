bossFour = Body:new{
	size = 60,
	width = 400,
	height = 300,
	sizeGrowth = 0,
	maxsize = width,
	basespeed = 1.5*v,
	maxhealth = 60,
	vulnerable = false,
	spriteBatch = false,
	shader = base.circleShader,
	linewidth = 1,
	ord = 6,
	__type = 'bossFour'
}

Body.makeClass(bossFour)

bossFour.behaviors = {}

function bossFour.behaviors.arriving( self )
	local curdist = self.position:distsqr(width/2, height/2)
	if curdist < 1 or curdist > self.prevdist then
		self.speed:reset()
		self.currentBehavior = bossFour.behaviors.first
		local components = {{},{},{},{}}
		for i = 1, 48 do
			local e = self:getShot()
			self:prepare(e)
			components[math.floor((i-1)/12) + 1][((i-1) % 12) + 1] = e
		end
		local f = formations.around:new{
			angle = 0,
			target = Vector:new{width/2, height/2},
			anglechange = base.toRadians(30),
			distance = 0,
			adapt = false,
			speed = 1.1*v,
			shootattarget = true
		}
		f:applyOn(components[1])
		f.angle = base.toRadians(7)
		f.radius = f.radius + width/3
		f:applyOn(components[2])
		f.angle = base.toRadians(14)
		f.radius = f.radius + width/3
		f:applyOn(components[3])
		f.angle = base.toRadians(21)
		f.radius = f.radius + width/3
		f:applyOn(components[4])

		f.radius = width
		f.angle = 0
		f.target = self.position
		f.shootattarget = true
		self.form = f

		Timer:new{
			timelimit = 5,
			onceonly = true,
			running = true,
			funcToCall = function()
				self.replacetimer:start()
				self.shoottimer:start()
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
		self.currentBehavior = bossFour.behaviors.second
		self.collides = true
		self.speed:set(1,1):normalize():mult(v/2, v/2):rotate(math.random()*2*math.pi)
		self.vulnerable = false
		self.colors[1]:setAndGo(nil, 0, 100)
		self.colors[2]:setAndGo(nil, 50, 100)
		self.colors[3]:setAndGo(nil, 25, 100)
		self.colors[1].alsoCall = function()
			self.colors[1].alsoCall = nil
			self.vulnerable = true
			self.health = bossFour.maxhealth*.75
		end
	end
end

function bossFour.behaviors.second( self )
	if self.health/bossFour.maxhealth < .5 then
		self.currentBehavior = bossFour.behaviors.tocenter
		self.speed:set(width/2, height/2):sub(self.position):normalize():mult(v*.5)
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
		self.speed:reset()
		self.currentBehavior = base.doNothing
		
		self.dontattack = true
		Timer:new{
			timelimit = 1.1,
			onceonly = true,
			running = true,
			funcToCall = function()
				self.cage = {}
				local angchange = base.toRadians(360/30)
				local pos = Vector:new{0, 200}
				local possible = {}
				for _, b in ipairs(self.pool) do if b.inBox then table.insert(possible, b) end end
				if #possible < 30 then
					local lim = 30 - #possible
					for i = 1, lim do
						local e = self:getShot()
						Enemy.__init(e)
						e.position:set(self.position)
						self:prepare(e)
						e.inBox = true
						table.insert(possible, e)
					end
				end
				if #self.pool < 50 then
					local lim = 50 - #self.pool
					for i = 1, lim do
						local e = self:getShot()
						Enemy.__init(e)
						e.position:set(self.position)
						self:prepare(e)
						e.inBox = true
					end
				end
				for i = 1, 30 do
					local s = possible[i]
					s.ignoreBox = true
					s.onCage = true
					s.target = pos + self.position
					s.prevdist = s.position:distsqr(s.target)
					s.speed:set(s.target):sub(s.position):normalize():mult(bossFour.basespeed)
					s.inBox = true
					pos:rotate(angchange)
					table.insert(self.cage, s)
				end
				self.poolN = self.poolN + 40
				self.dontattack = false
				self.currentBehavior = bossFour.behaviors.third
			end
		}
		Timer:new{
			timelimit = 2.1,
			onceonly = true,
			running = true,
			funcToCall = function()
				self.colors[1]:setAndGo(nil, 0, 100)
				self.colors[2]:setAndGo(nil, 122, 100)
				self.colors[3]:setAndGo(nil, 122, 100)
				self.colors[1].alsoCall = function()
					self.colors[1].alsoCall = nil
					self.vulnerable = true
					self.health = bossFour.maxhealth*.5
				end
			end
		}
	end
end

function bossFour.behaviors.third( self )
	for i = 1, 30 do
		local s = self.cage[i]
		if s.delete then
			local new = nil
			for _, b in ipairs(self.pool) do if not b.onCage and b.inBox then new = b break end end
			if new then
				new.onCage = true
				new.target = s.target
				new.prevdist = new.position:distsqr(new.target) + 10
				new.speed:set(new.target):sub(new.position):normalize():mult(bossFour.basespeed/2)
			end
			self.cage[i] = new or s
		else
			if s.prevdist then
				local curdist = s.position:distsqr(s.target)
				if curdist < 1 or curdist > s.prevdist then
					s.position:set(s.target)
					s.prevdist = nil
					s.speed:reset()
				else
					s.prevdist = curdist
				end
			else
				s.speed:reset()
			end
		end
	end
	if self.health/bossFour.maxhealth < .25 then
		self.sizeGrowth = -20
		self.desiredsize = 20
		self.cage = nil
		self.shoottimer:remove()
		self.replacetimer:remove()
		for _, b in ipairs(self.pool) do
			b.speed:set(self.position):sub(b.position):normalize():mult(bossFour.basespeed/2)
			b.prevdist = b.position:distsqr(self.position)
		end
		self.currentBehavior = bossFour.behaviors.gathering
		self.vulnerable = false
		self.colors[1]:setAndGo(nil, 122, 100)
		self.colors[2]:setAndGo(nil, 122, 100)
		self.colors[3]:setAndGo(nil, 122, 100)
	end
end

function bossFour.behaviors.gathering ( self )
	for _, b in ipairs(self.pool) do
		if b.prevdist then
			local curdist = b.position:distsqr(self.position)
			if curdist < 1 or curdist > b.prevdist then
				b.speed:reset()
				b.prevdist = nil
				b.delete = true
			else
				b.prevdist = curdist
			end
		else
			b.speed:set(self.position):sub(b.position):normalize():mult(bossFour.basespeed/2)
			b.prevdist = b.position:distsqr(self.position)
		end
	end
	if #self.pool == 0 and self.desiredsize == nil and not self.recharging then
		self.currentBehavior = bossFour.behaviors.final
		self.pool = nil
		self.form.radius = 3
		self.getShot = function() return (math.random() < .5 and enemies.monoguiaball or enemies.grayball):new{} end
		self.colors[1]:setAndGo(nil, .59*225, 100)
		self.colors[2]:setAndGo(nil, .44*255, 100)
		self.colors[3]:setAndGo(nil, .9*255, 100)
		self.colors[1].alsoCall = function()
			self.colors[1].alsoCall = nil
			self.health = bossFour.maxhealth*.25
			self.vulnerable = true
		end
		self.shoottimer = Timer:new {
			timelimit = 1,
			running = true,
			funcToCall = function ()
				self.form.angle = math.random()*math.pi
				local n = math.random(14, 22)
				self.form.anglechange = base.toRadians(360/n)
				local es = {}
				for i = 1, n do
					local e = self:getShot()
					table.insert(es, e)
					e:register()
				end
				self.form:applyOn(es)
			end
		}
	end
end

function bossFour.behaviors.final( self )
	if self.health == 0 then
		self.delete = true
		self.shoottimer:remove()
	end
end

function bossFour:update( dt )
	if self.pool then
		for i = #self.pool, 1, -1 do
			local p = self.pool[i]
			p:update(dt)
			if p.delete then 
				p:handleDelete() 
				table.remove(self.pool, i)
			end
		end
	end

	Body.update(self, dt)
	CircleEffect.update(self, dt)
	self:currentBehavior()

	if self.collides then
		if self.x + self.width/2 > width then self.speed:set(-math.abs(self.Vx))
		elseif self.x - self.width/2 < 0 then self.speed:set( math.abs(self.Vx)) end

		if self.y + self.height/2 > height then self.speed:set(nil, -math.abs(self.Vy))
		elseif self.y - self.height/2 < 0 then self.speed:set(nil,  math.abs(self.Vy)) end
	end

	if psycho.canbehit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end

	for _, s in pairs(Shot.bodies) do
		if self:collidesWith(s) then
			s.collides = true
			s.explosionEffects = true
			if self.health > 0 and self.vulnerable then
				self.health = self.health - 1
				local d = self.health/bossFour.maxhealth
				if self.currentBehavior == bossFour.behaviors.first then
					d = (math.max(d,.75)-.75)*4
					self.colors[1]:setAndGo(nil, 255, 1200)
					--self.colors[2] is already correct
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossFour.behaviors.first then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[3]:setAndGo(nil, d*255, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.second then
					d = (math.max(d,.5)-.5)*4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossFour.behaviors.second then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[2]:setAndGo(nil, d*50, 400)
							self.colors[3]:setAndGo(nil, d*25, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.third then
					d = (math.max(d,.25)-.25)/(.5 - .25)
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
						if self.currentBehavior == bossFour.behaviors.third then
							self.colors[1]:setAndGo(nil, (1-d)*255, 400)
							self.colors[2]:setAndGo(nil, d*122, 400)
							self.colors[3]:setAndGo(nil, d*122, 400)
						end
					end
					}
				elseif self.currentBehavior == bossFour.behaviors.final then
					d = math.max(d, 0)*4
					self.colors[1]:setAndGo(nil, 255, 1200)
					self.colors[2]:setAndGo(nil, 0, 1200)
					self.colors[3]:setAndGo(nil, 0, 1200)
					Timer:new{timelimit = .05, onceonly = true, running = true, funcToCall = function()
						self.colors[1]:setAndGo(nil, .59*225 + (1-d)*.41*255, 400)
						self.colors[2]:setAndGo(nil, .44*255*d, 400)
						self.colors[3]:setAndGo(nil, .9*255*d, 400)
					end
					}
				end
			end
		end
	end
end

function bossFour:draw()
	if self.pool then
		for k, p in pairs(self.pool) do
			base.defaultDraw(p)
		end
	end
	base.defaultDraw(self)
end

function bossFour:prepare( enemy )
	if not self.pool then return end
	enemy.spriteBatch = false
	enemy.update = self.updateFunc
	enemy:freeWarning()
	table.insert(self.pool, enemy)
end

function bossFour:getShot()
	return (math.random() < .4 and enemies.monoguiaball or enemies.multiball):new{}
end

function bossFour:grow( n )
	local es = {}
	for i = 1, n do
		local e = self:getShot()
		e:getWarning()
		table.insert(es, e)
	end
	Timer:new{ 
		timelimit = 1,
		running = true,
		onceonly = true,
		funcToCall = function()
			for _, e in ipairs(es) do
				e.speed:set(self.position):sub(e.position):normalize():mult(self.basespeed)
				self:prepare(e)
			end
		end
	}
end

function bossFour:__init()
	self.health = bossFour.maxhealth
	self.position:set(0, 0)
	self.poolN = 50
	self.speed:set(width/2, height/2):normalize():mult(self.basespeed)
	self.prevdist = self.position:distsqr(width/2, height/2)
	self.pool = {}
	self.currentBehavior = bossFour.behaviors.arriving
	self.updateFunc =  function (e, dt)
			if not e.inBox then
				e.speed:set(self.position):sub(e.position):normalize():mult(v*1.5)
			end
			e:__super().update(e, dt)
			if e.ignoreBox then return end
			if not e.inBox and base.collides(e, self) then 
				e.inBox = true
				e.speed:set((math.random()*v*.3 + v*1.4)*base.sign(math.random()-.5), (math.random()*v*.3 + v*1.4)*base.sign(math.random()-.5))
				e.positionfollows = nil
			end
			if not e.inBox then return end
			if e.x  + e.size > (e.rx or (self.x + self.width/2)) then e.speed:set(-math.abs(e.Vx))
			elseif e.x - e.size < (e.lx or (self.x - self.width/2)) then e.speed:set( math.abs(e.Vx)) end

			if e.y + e.size > (e.by or (self.y + self.height/2)) then e.speed:set(nil, -math.abs(e.Vy))
			elseif e.y - e.size < (e.ty or (self.y - self.height/2)) then e.speed:set(nil,  math.abs(e.Vy)) end
		end
	self.colors = {VarTimer:new{var = 122}, VarTimer:new{var = 122}, VarTimer:new{var = 122}, VarTimer:new{var = 10}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(unpack(self.colors))
	self.shoottimer = Timer:new{
		timelimit = .1,
		funcToCall = function()
			if not self.recharging and math.random() < .1 then self:grow(1) end
			if not self.recharging and not self.dontattack and math.random() < .4 then
				local n = #self.pool
				local p1 = math.random(n)
				self.pool[n], self.pool[p1] = self.pool[p1], self.pool[n]
				p1 = self.pool[n]
				if (not p1.inBox) or p1.ignoreBox then return end
				p1.ignoreBox = true
				p1.speed:set(psycho.position):sub(p1.position):normalize():mult(bossFour.basespeed)
			end
		end
	}
	self.replacetimer = Timer:new{
		timelimit = .1,
		funcToCall = function()
 			if not self.recharging and #self.pool/self.poolN < .4 then
				local es = {{},{},{},{},{},{}}
				for i = 1, 72 do
					local e = self:getShot()
					es[math.floor((i-1)/12) + 1][((i-1) % 12) + 1] = e
				end
				self.recharging = true
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
					timelimit = 1.5,
					onceonly = true,
					running = true,
					funcToCall = function()
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
end

function bossFour:handleDelete()
	neweffects(self, 200)
end