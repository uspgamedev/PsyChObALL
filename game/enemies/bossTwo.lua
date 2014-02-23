local max, random, abs, pairs = math.max, math.random, math.abs, pairs

bossTwo = Body:new {
	size = 80,
	maxHealth = 35,
	baseSpeed = v,
	ballsDistance = 49,
	alpha = 255,
	mode = 'fill',
	sizeGrowth = 0,
	vulnerable = true,
	shader = Base.circleShader,
	maxSize = width,
	ord = 7,
	__type = 'bossTwo'
}

Body.makeClass(bossTwo)

bossTwo.behaviors = {}

function bossTwo:revive()
	Body.revive(self)

	self.variance = 6
	self.position:set(200, 200)
	self.ballsSpeed = 0
	self.ballsColor = {
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}},
		{VarTimer:new{var = 0}, VarTimer:new{var = 120}, VarTimer:new{var = 0}}
	}

	self.ballsColorEffect = {
		ColorManager.getColorEffect(self.ballsColor[1][1], self.ballsColor[1][2], self.ballsColor[1][3], 20),
		ColorManager.getColorEffect(self.ballsColor[2][1], self.ballsColor[2][2], self.ballsColor[2][3], 20),
		ColorManager.getColorEffect(self.ballsColor[3][1], self.ballsColor[3][2], self.ballsColor[3][3], 20),
		ColorManager.getColorEffect(self.ballsColor[4][1], self.ballsColor[4][2], self.ballsColor[4][3], 20)
	}

	bossTwo.turrets = { 
		bossTwo.turret:new{ position = Vector:new{ 0, -50 } }, 
		bossTwo.turret:new{ position = Vector:new{  50, 0 } }, 
		bossTwo.turret:new{ position = Vector:new{ 0,  50 } }, 
		bossTwo.turret:new{ position = Vector:new{ -50, 0 } }
	}

	self.healths = { bossTwo.maxHealth, bossTwo.maxHealth, bossTwo.maxHealth, bossTwo.maxHealth }
	self.currentBehavior = bossTwo.behaviors.arriving
	self.position:set(-200, -200)
	self.speed:set(width/2, height/2):sub(self.position):normalize():mult(1.5 * self.baseSpeed, 1.5 * self.baseSpeed)
	self.prevdist = self.position:distsqr(width/2, height/2)

	function bossTwo:getTurretShot()
		return Body.reviveAndCopy(Enemies.simpleball.bodies:getFirstAvailable(), { score = false })
	end

	return self
end

function bossTwo.behaviors.arriving( self )
	local curdist = self.position:distsqr(width/2, height/2)
	if curdist < 1 or curdist > self.prevdist then -- arrived in the middle
		self.prevdist = nil
		self.position:set(width/2, height/2)
		self.speed:set(0, 0)

		self.shootTimer = Timer:new {
			timeLimit = 1.6,
			worksOnGameLost = false,
			time = random(),
			running = true
		}

		function self.shootTimer.callback( timer )
			local e = self:getShot()
			e.position:set(self.position)
			e.speed:set(psycho.position):sub(self.position):normalize():mult(1.5 * v, 1.5 * v)
			e:register()
		end

		Timer:new{ timeLimit = 2, running = true, onceOnly = true, callback = function()
				local pos = {{90, 90}, {width - 90, 90}, {width - 90, height - 90}, {90, height - 90}}
				self.turretsOldPosition = {0, 0, 0, 0}

				-- move turrets to position
				for i = 1, 4 do 
					local t = bossTwo.turrets[i]
					self.turretsOldPosition[i] = t.position + self.position
					t:detach(self.position)
					t.speed:set(pos[i]):sub(t.position):normalize():mult(bossTwo.baseSpeed, bossTwo.baseSpeed)
					t.target = pos[i]
					t.prevdist = t.position:distsqr(t.target)
				end

				Timer:new {
					timeLimit = .1,
					running = true,
					callback = function(timer)
						for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
						-- when all turrets are in position
						for i = 1, 4 do bossTwo.turrets[i].shootTimer:start(0) end
						timer:remove()
					end
				}

				self.sizeGrowth = -30
				self.ballsSpeed = -10
			end
		}

		self.currentBehavior = bossTwo.behaviors.first -- change behavior
	else
		self.prevdist = curdist
	end
end

function bossTwo.behaviors.first( self )
	-- shrink to size 60
	if self.size < 60 then self.sizeGrowth = 0 self.size = 60 end
	-- get balls closer
	if self.ballsDistance < 35 then self.ballsSpeed = 0 self.ballsDistance = 35 end
	

	if self.sizeGrowth == 0 and self.size == 60 and self.ballsSpeed == 0 and self.ballsDistance == 35 and max(unpack(self.healths))/bossTwo.maxHealth <= .75 then
		for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
		RecordsManager.addScore(500)

		bossTwo.turrets[1].speed:set(v,  0)
		bossTwo.turrets[2].speed:set(0,  v)
		bossTwo.turrets[3].speed:set(-v, 0)
		bossTwo.turrets[4].speed:set(0, -v)
		
		self.currentBehavior = bossTwo.behaviors.second -- change behavior

		--change shot to multiball
		self.getShot = function () return Body.reviveAndCopy(Enemies.multiball.bodies:getFirstAvailable(), { score = false }) end
		
		bossTwo.getTurretShot = self.getShot
		
		for i = 1, 4 do
			bossTwo.turrets[i].restrictToScreenThreshold = 20
			bossTwo.turrets[i].restrictToScreenSpeed = v
			self.healths[i] = bossTwo.maxHealth * .75

			-- change balls colors
			local c = self.ballsColor[i]
			c[1]:setAndGo(nil, 0, 120)
			c[2]:setAndGo(nil, 50, 120)
			c[3]:setAndGo(nil, 140, 120)
		end
	end
end

function bossTwo.behaviors.second( self )
	-- keep turrets on screen
	for i = 1, 4 do bossOne.restrictToScreen(bossTwo.turrets[i]) end

	if max(unpack(self.healths))/bossTwo.maxHealth <= .5 then
		RecordsManager.addScore(750)

		for i = 1, 4 do
			-- turrets go back to their old positions
			local t = bossTwo.turrets[i]
			local targ = self.turretsOldPosition[i]
			t.onLocation = false
			t.target = targ
			t.prevdist = t.position:distsqr(targ)
			t.speed:set(targ):sub(t.position):normalize():mult(bossTwo.baseSpeed)
			t.shootTimer:stop()

			-- change balls colors
			local c = self.ballsColor[i]
			c[1]:setAndGo(nil, 122, 120)
			c[2]:setAndGo(nil, 122, 120)
			c[3]:setAndGo(nil, 122, 120)
		end

		self.turretsOldPosition = nil
		
		self.vulnerable = false
		
		-- now shots glitchballs
		self.getShot = function() return Enemies.glitchball.bodies:getFirstAvailable():revive() end
		bossTwo.getTurretShot = self.getShot

		self.currentBehavior = bossTwo.behaviors.gathering -- change behavior
		self.sizeGrowth = 30
		self.ballsSpeed = 10
	end
end

function bossTwo.behaviors.gathering( self )
	-- grow to normal size
	if self.size > bossTwo.size then self.sizeGrowth = 0 self.size = bossTwo.size end
	-- get balls to normal position
	if self.ballsDistance > bossTwo.ballsDistance then self.ballsSpeed = 0 self.ballsDistance = bossTwo.ballsDistance end
	

	if self.sizeGrowth == 0 and self.ballsSpeed == 0 and self.size == bossTwo.size and self.ballsDistance == bossTwo.ballsDistance then
		for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end

		for i = 1, 4 do
			-- attach turrets to self
			local t = bossTwo.turrets[i]
			t:attach(self.position)
		end

		Timer:new {
			timeLimit = 1,
			running = true,
			onceOnly = true,
			callback = function()
				if self.currentBehavior ~= bossTwo.behaviors.third then return end

				for i = 1, 4 do
					-- move turrets
					local t = bossTwo.turrets[i]
					t.onLocation = false
					t.target = t.position:normalized():mult(width/2 - 90, height/2 - 90)
					t.speed:set(t.position):normalize():mult(bossTwo.baseSpeed)
					t.prevdist = t.position:distsqr(t.target)
					t.shootTimer:start(-2)
				end

				self.rotatetimer:start(0)
			end
		}

		Timer:new{
			timeLimit = 3.5,
			running = true,
			onceOnly = true,
			callback = function()

				for i = 1, 4 do
					-- changes the balls colors
					local c = self.ballsColor[i]
					c[1]:setAndGo(nil, 80, 120)
					c[2]:setAndGo(nil, 90, 120)
					c[3]:setAndGo(nil, 0, 120)
					self.healths[i] = bossTwo.maxHealth * .5
				end

				-- makes everything vulnerable again
				self.vulnerable = true
			end
		}

		self.rotatetimer = Timer:new {
			timeLimit = 2.5,
			callback = function( timer )
				for i = 1, 4 do
					-- moves turrets to next turret position
					local t = bossTwo.turrets[i]
					local n = bossTwo.turrets[(i % 4) + 1]
					t.onLocation = false
					t.target = n.position:clone()
					t.speed:set(t.target):sub(t.position):normalize():mult(bossTwo.baseSpeed)
					t.prevdist = t.position:distsqr(t.target)
				end
			end
		}

		self.currentBehavior = bossTwo.behaviors.third -- changes behavior
	end
end

function bossTwo.behaviors.third( self )
	if max(unpack(self.healths))/bossTwo.maxHealth <= .25 then
		RecordsManager.addScore(750)

		self.rotatetimer:remove()
		self.rotatetimer = nil

		local tpos = {{0, -150}, {150, 0}, {0, 150}, {-150, 0}}
		for i = 1, 4 do
			-- move turrets
			local t = bossTwo.turrets[i]
			t.target = tpos[i]
			t.onLocation = false
			t.speed:set(t.target):sub(t.position):normalize():mult(bossTwo.baseSpeed)
			t.prevdist = t.position:distsqr(t.target)
			t.shootTimer:stop()

			Timer:new{
				timeLimit = .1,
				time = -1,
				running = true,
				callback = function( timer )
					for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end end
					-- when all turrets are in position, begin creating cage
					local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
					local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]

					c1.speed:set(c1.position):normalize():mult(v/4, v/4)
					c2.speed:set(c2.position):normalize():mult(v/4, v/4)

					c1.sizeGrowth = 10
					c2.sizeGrowth = 10
					c3.sizeGrowth = -10
					c4.sizeGrowth = -10

					timer:remove()
				end
			}

			-- change balls colors
			local c = self.ballsColor[i]
			c[1]:setAndGo(nil, 122, 100)
			c[2]:setAndGo(nil, 122, 100)
			c[3]:setAndGo(nil, 122, 100)
		end

		self.sizeGrowth = -30
		self.ballsSpeed = -10
		self.shootTimer:stop()
		self.currentBehavior = bossTwo.behaviors.caging -- change behavior
	end
end

function bossTwo.behaviors.caging( self )
	-- shrink to size 60
	if self.size < 60 then self.sizeGrowth = 0 self.size = 60 end
	-- get balls closer
	if self.ballsDistance < 35 then self.ballsSpeed = 0 self.ballsDistance = 35 end


	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
		local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]

		-- delete c3 and c4 when they get too small
		if c3 and c3.size <= 0 then t.circles[i] = nil end
		if c4 and c4.size <= 0 then t.circles[i == 3 and 1 or ((i % 4) + 2)] = nil end

		-- grow c1 and c2 to size 50
		if c1.size > 50 then c1.sizeGrowth = 0 c1.size = 50 end
		if c2.size > 50 then c2.sizeGrowth = 0 c2.size = 50 end

		if c1.position:lengthsqr() > 80*80 then c1.speed:set(0,0) c1.position:normalize():mult(80) end
		if c2.position:lengthsqr() > 80*80 then c2.speed:set(0,0) c2.position:normalize():mult(80) end
	end

	if self.size == 60 and self.ballsDistance == 35 and self.sizeGrowth == 0 and self.ballsSpeed == 0 then

		for i = 1, 4 do
			local t = bossTwo.turrets[i]
			local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
			local c3, c4 = t.circles[i], t.circles[i == 3 and 1 or ((i % 4) + 2)]
			if c3 or c4 then return end
			if c1.size ~= 50 or c2.size ~= 50 or c1.sizeGrowth ~= 0 or c2.sizeGrowth ~= 0 then return end
			if not (c1.speed:equals(0, 0) and c2.speed:equals(0, 0)) then return end
		end
		-- continue when all balls are in placeand properly grown

		for i = 1, 4 do
			-- change balls colors
			local c = self.ballsColor[i]
			c[1]:setAndGo(nil, 0, 100)
			c[2]:setAndGo(nil, 240, 100)
			c[3]:setAndGo(nil, 0, 100)

			local t = bossTwo.turrets[i]
			t.shootTimer:start()
			-- rearrange circles to make stuff easier
			local c1, c2 = t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1]
			t.circles[(i % 4) + 1], t.circles[((i-2) % 4) + 1] = nil, nil
			t.circles[1], t.circles[2] = c1, c2

			c1.growafter = Timer:new{
				timeLimit = 1.5,
				callback = function( timer )
					c1.sizeGrowth = 3
					timer:stop()
				end
			}

			c2.growafter = Timer:new{
				timeLimit = 1.5,
				callback = function( timer )
					c2.sizeGrowth = 3
					timer:stop()
				end
			}

			self.healths[i] = bossTwo.maxHealth * .25
		end

		self.currentBehavior = bossTwo.behaviors.fourth -- change behavior
	end
end

function bossTwo.behaviors.fourth( self )
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		local c1, c2 = t.circles[1], t.circles[2]

		if c1 then
			c1.position:add(t.position):add(t.bossTwopos)
			-- grow no bigger than 50
			if c1.size > 50 then c1.sizeGrowth = 0 c1.size = 50 end
		end

		if c2 then 
			c2.position:add(t.position):add(t.bossTwopos)
			-- grow no bigger than 50
			if c2.size > 50 then c2.sizeGrowth = 0 c2.size = 50 end
		end

		if c1 or c2 then
			Shot.bodies:forEachAlive(function(shot)
				local c1c, c2c = shot:collidesWith(c1), shot:collidesWith(c2)
				local c = c1c and c1 or c2
				if c1c or c2c then
					-- shrink a bit
					c.size = max(c.size - 3, 5)
					
					-- start or reset growth timer
					c.growafter:start(0)

					shot.explosionEffects = true
					shot:kill()
				end
			end)
		end

		if c1 then c1.position:sub(t.position):sub(t.bossTwopos) end
		if c2 then c2.position:sub(t.position):sub(t.bossTwopos) end
	end

	if max(unpack(self.healths)) <= 0 then
		RecordsManager.addScore(750)
		
		for i = 1, 4 do
			-- move turrets
			local t = bossTwo.turrets[i]
			t.shootTimer:stop()
			t.target = t.position:normalized():mult(width/2 - 85, height/2 - 85)
			t.speed:set(t.target):sub(t.position):div(2, 2)
			t.onLocation = false
			t.prevdist = t.position:distsqr(t.target)

			-- kill circles
			local c1, c2 = t.circles[1], t.circles[2]

			if c1 then
				c1.position:add(t.position):add(t.bossTwopos)
				Effect.createEffects(c1, 30)
				t.circles[1] = nil
			end

			if c2 then
				c2.position:add(t.position):add(t.bossTwopos)
				Effect.createEffects(c2, 30)
				t.circles[2] = nil
			end
		end

		self.sizeGrowth = -10
		self.ballsSpeed = -20
		self.currentBehavior = bossTwo.behaviors.imploding -- change behavior
	end
end

function bossTwo.behaviors.imploding( self )
	-- grow to size 50
	if self.size < 50 then self.sizeGrowth = 0 self.size = 50 end
	-- centralize balls
	if self.ballsDistance < 0 then self.ballsSpeed = 0 self.ballsDistance = 0 end


	if self.sizeGrowth ~= 0 or self.ballsSpeed ~= 0 or self.size ~= 50 or self.ballsDistance ~= 0 then return end
	for i = 1, 4 do if not bossTwo.turrets[i].onLocation then return end	end
	-- at this point, all turrets and balls are on location

	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		t.lifecircle = Body.reviveAndCopy(CircleEffect.bodies:getFirstAvailable(), 
			{ alpha = 255, size = t.size, sizeGrowth = 35, position = t.position + self.position, lineWidth = 5 })

		function t.lifecircle.update( circle, dt )
			CircleEffect.update(circle, dt)

			if circle.size > t.size + 60 then circle.sizeGrowth = 0 circle.size = t.size + 60 t.shootTimer:start(t.shootTimer.timeLimit) end
			
			if circle.size < t.size then 
				circle:kill()
			end
		end

		function t.lifecircle.kill( circle )
			CircleEffect.kill(circle)

			t.position:set(circle.position) 
			Effect.createEffects(t, 100) 
			t.shootTimer:remove() 
			t:kill()
			bossTwo.turrets[i] = nil
			for _, tur in pairs(bossTwo.turrets) do tur.shootTimer.timeLimit = tur.shootTimer.timeLimit/1.5 end
		end

		-- turrets don't move anymore
		t.update = Base.doNothing
	end

	self.currentBehavior = bossTwo.behaviors.turretprotection -- change behavior
end

function bossTwo.behaviors.turretprotection( self )
	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t and t.lifecircle.sizeGrowth == 0 then
			Shot.bodies:forEachAlive(function(shot)
				if shot:collidesWith(t.lifecircle) then
					t.lifecircle.size = t.lifecircle.size - 2

					shot.explosionEffects = true
					shot:kill()
				end
			end)
		end
	end

	for i = 1, 4 do if bossTwo.turrets[i] then return end end
	-- when all turrets are dead
	local a = VarTimer:new{}
	a:setAndGo(0, 255, 100)

	self.plead = Body.reviveAndCopy(Text.bodies:getFirstAvailable(), {
		text = "Please don't kill me!",
		font = Base.getCoolFont(30),
		position = Vector:new{width/2 - 146, height/2 - 110},
		alphaFollows = a
	})

	self.plead:register()

	-- fade out
	Timer:new{ timeLimit = 4, onceOnly = true, running = true, callback = function ()
		a.alsoCall = function() self.plead:kill() self.plead = nil end
		a:setAndGo(255, 0, 100)
	end}

	Timer:new{ timeLimit = 1, onceOnly = true, running = true, callback = function ()
		self.ballsColor[4][1]:setAndGo(nil, 0, 100)
		self.ballsColor[4][2]:setAndGo(nil, 255, 100)
		self.ballsColor[4][3]:setAndGo(nil, 0, 100)
		self.currentBehavior = bossTwo.behaviors.final
	end}
	
	self.healths[1] = 100
	self.currentBehavior = Base.doNothing
end

function bossTwo.behaviors.final( self )

	if self.healths[1] < 100 then
		self.size = self.healths[1]/2
	end

	if self.size < 10 then
		RecordsManager.addScore(2000)
		self:kill()
		Effect.createEffects(self, 100)
	end
end

function bossTwo:draw()
	local xt, yt = self.position:unpack()

	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t then t:draw(xt, yt) end
	end

	local bp = self.ballsDistance
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballsColorEffect[1]))
	graphics.circle(self.mode, xt - bp, yt - bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballsColorEffect[2]))
	graphics.circle(self.mode, xt + bp, yt - bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballsColorEffect[3]))
	graphics.circle(self.mode, xt - bp, yt + bp, self.size)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.ballsColorEffect[4]))
	graphics.circle(self.mode, xt + bp, yt + bp, self.size)
end

function bossTwo:collides( v, n )
	return (v.size + self.size)^2 >= (v.x - self.x - (n % 2 == 0 and 1 or -1) * self.ballsDistance)^2 + (v.y - self.y - (n > 2 and 1 or -1) * self.ballsDistance)^2
end

function bossTwo:getShot()
	return Body.reviveAndCopy((random() < .5 and Enemies.simpleball or Enemies.multiball).bodies:getFirstAvailable(), { score = false })
end

function bossTwo:update( dt )
	CircleEffect.update(self, dt)
	Body.update(self, dt)
	self:currentBehavior()

	for i = 1, 4 do
		local t = bossTwo.turrets[i]
		if t then t:update(dt) end
	end

	self.ballsDistance = self.ballsDistance + self.ballsSpeed * dt

	Shot.bodies:forEachAlive(function(shot)
		local c1, c2, c3, c4 = self:collides(shot, 1), self:collides(shot, 2), self:collides(shot, 3), self:collides(shot, 4)
		if c1 or c2 or c3 or c4 then
			shot.explosionEffects = true
			shot:kill()

			local n = c1 and 1 or c2 and 2 or c3 and 3 or 4

			if self.healths[n] > 0 and self.vulnerable then 
				self.healths[n] = self.healths[n] - 1
				local d = self.healths[n]/bossTwo.maxHealth
				if self.currentBehavior == bossTwo.behaviors.arriving or self.currentBehavior == bossTwo.behaviors.first then
					d = (max(d,.75) - .75) * 4
					local colors = self.ballsColor[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3] is already correct
						Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
							local colors = self.ballsColor[n]
							colors[1]:setAndGo(nil, (1 - d) * 255, 300)
							colors[2]:setAndGo(nil, d * 120, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.second then
					d = (max(d, .5) - .5) * 4
					local colors = self.ballsColor[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						colors[3]:setAndGo(0, 700)
						Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
							colors[1]:setAndGo(nil, (1 - d) * 255, 300)
							colors[2]:setAndGo(nil, d * 50, 300)
							colors[3]:setAndGo(nil, d * 140, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.third then
					d = (max(d, .25) - .25) * 4
					local colors = self.ballsColor[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3]:setAndGo(0, 700)
						Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
							colors[1]:setAndGo(nil, 80 + (1 - d) * (255 - 80), 300)
							colors[2]:setAndGo(nil, d * 90, 300)
							--colors[3]:setAndGo(nil, d*255, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.fourth then
					self.healths[n] = max(self.healths[n] - 2, 0)
					d = self.healths[n]/bossTwo.maxHealth
					d = max(d, 0) * 4
					local colors = self.ballsColor[n]
					if d == 0 then
						colors[1]:setAndGo(nil, 122, 100)
						colors[2]:setAndGo(nil, 122, 100)
						colors[3]:setAndGo(nil, 122, 100)
					else
						colors[1]:setAndGo(255, 700)
						colors[2]:setAndGo(0, 700)
						--colors[3]:setAndGo(0, 700)
						Timer:new{timeLimit = .05, onceOnly = true, running = true, callback = function()
							colors[1]:setAndGo(nil, (1 - d) * 255, 300)
							colors[2]:setAndGo(nil, d * 240, 300)
							--colors[3]:setAndGo(nil, d*255, 300)
						end
						}
					end
				elseif self.currentBehavior == bossTwo.behaviors.final then
					self.healths[n] = self.healths[n] - 4
				end
			end
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and (self:collides(psycho, 1) or self:collides(psycho, 2) or self:collides(psycho, 3) or self:collides(psycho, 4)) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end
end

bossTwo.turret = Body:new {
	size = 60,
	health = bossTwo.maxHealth/4,
	variance = random() * ColorManager.colorCycleTime,
	ballscoloreffect = ColorManager.getColorEffect(175, 0, 0, 40),
	coloreffect = ColorManager.noLSDEffect,
	attached = true,
	__type = 'bossTwoTurret'
}

Body.makeClass(bossTwo.turret)

function bossTwo.turret:__init()
	self.shootTimer = Timer:new {
		timeLimit = 1.5,
		callback = function ()
			local e = bossTwo:getTurretShot()

			e.position:set(self.position)
			if self.attached then e.position:add(self.bossTwopos) end

			e.speed:set(psycho.position):sub(e.position):normalize():mult(bossTwo.baseSpeed)
			e:register()
		end
	}
	
	self.circles = {
		CircleEffect:new{ alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{0, -55}},
		CircleEffect:new{ alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{ 55, 0}},
		CircleEffect:new{ alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{0,  55}},
		CircleEffect:new{ alpha = 255, mode = 'fill', size = 30, sizeGrowth = 0, coloreffect = self.ballscoloreffect, position = Vector:new{-55, 0}}
	}

	self.bossTwopos = Vector:new{}
end

function bossTwo.turret:draw( xt, yt )
	if self.attached then self.bossTwopos:set(xt, yt)
	else self.bossTwopos:set(0, 0) end

	local x, y = self.bossTwopos[1] + self.position[1], self.bossTwopos[2] + self.position[2]
	graphics.translate(x, y)

	for _, c in pairs(self.circles) do c:draw() end

	graphics.translate(-x, -y)
	graphics.setColor(ColorManager.getComposedColor(self.variance, 255, self.coloreffect))
	graphics.circle(self.mode, x, y, self.size)
end

local auxVec = Vector:new{}

function bossTwo.turret:update( dt )
	Body.update(self, dt)

	for _, c in pairs(self.circles) do
		c:update(dt)
		c.position:add(auxVec:set(c.speed):mult(dt))
	end

	if not self.onLocation and self.target then
		local curdist = self.position:distsqr(self.target)
		if curdist < 1 or curdist > self.prevdist then
			self.speed:reset()
			self.prevdist = nil
			self.onLocation = true
			self.target = nil
		else
			self.prevdist = curdist
		end
	end

	self.position:add(self.bossTwopos)

	Shot.bodies:forEachAlive(function(shot)
		if self:collidesWith(shot) then
			if self.health > 0 then self.health = self.health - 1 end
			shot.explosionEffects = true
			shot:kill()
		end
	end)

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.causeOfDeath = "shot"
		DeathManager.manageDeath()
	end

	self.position:sub(self.bossTwopos)
end

function bossTwo.turret:detach( pos )
	if not self.attached then return end
	self.position:add(pos)
	self.attached = false
end

function bossTwo.turret:attach( pos )
	if self.attached then return end
	self.position:sub(pos)
	self.attached = true
end