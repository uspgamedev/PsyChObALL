bossLast = Body:new{
	size = 100,
	width = 400,
	height = 200,
	variance = 5,
	visible = true,
	maxhealth = 10,
	collides = true,
	spriteBatch = false,
	ord = 8,
	angle = nil, --VarTimer
	__type = 'bossLast'
}

Body.makeClass(bossLast)
local abs, random = math.abs, math.random

bossLast.behaviors = {}

function bossLast.behaviors.first( self )
	
end

function bossLast:draw()
	if not self.visible then return end
	graphics.setPixelEffect()
	graphics.push()
	graphics.setColor(ColorManager.getComposedColor(self.variance, self.alphaFollows.var, self.coloreffect))
	graphics.translate(self.x, self.y)
	graphics.rotate(self.angle.var)
	graphics.rectangle(self.mode, -self.width/2, -self.height/2, self.width, self.height)
	graphics.pop()
	graphics.setPixelEffect(Base.circleShader)
end

function bossLast:update( dt )
	Body.update(self, dt)
	if not self.visible then return end

	if self.collides then
		if self.x  + self.size > width then self.speed:set(-abs(self.Vx))
		elseif self.x - self.size < 0  then self.speed:set( abs(self.Vx)) end

		if self.y + self.size > height then self.speed:set(nil, -abs(self.Vy))
		elseif self.y - self.size < 0  then self.speed:set(nil,  abs(self.Vy)) end
	end

	for _, s in pairs(Shot.bodies) do
		if self:collidesWith(s) then
			s.collides = true
			s.explosionEffects = true
			if self.health > 0 then
				self.health = self.health - 1
				local d = self.health/bossLast.maxhealth
				self.colorchange.var = 255*d
				--stuff
			end
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end

	self:currentBehavior()
end

function bossLast.getShot()
	return Enemies.multiball:new{}
end

function bossLast:__init()
	self.position:set(width/2, height/2)
	self.angle = VarTimer:new{var = 0}
	self.visible = false
	self.alphaFollows = VarTimer:new{var = 0}
	self.health = bossLast.maxhealth
	self.colorchange = VarTimer:new{var = 255}
	self.coloreffect = ColorManager.getColorEffect({var = 255}, {var = 0}, {var = 0}, self.colorchange)
	self.currentBehavior = Base.doNothing

	local components = {{},{},{},{}}
	local updateFunc =  function (e, dt)
			Enemies.grayball.update(e, dt)
			if not e.inBox and Base.collides(e, self) then e.inBox = true end
			if not e.inBox then return end
			if e.x  + e.size > width/2 + self.width/2 + 20 then e.speed:set(-abs(e.Vx))
			elseif e.x - e.size < width/2 - self.width/2 - 20 then e.speed:set( abs(e.Vx)) end

			if e.y + e.size > height/2 + self.height/2 + 20 then e.speed:set(nil, -abs(e.Vy))
			elseif e.y - e.size < height/2 - self.height/2 - 20 then e.speed:set(nil,  abs(e.Vy)) end
		end
	local ballsalpha = VarTimer:new{var = 255}
	for i = 1, 160 do
		local e = Enemies.grayball:new{}
		e.coloreffect = Base.doNothing
		e.variance = 5
		e.alphaFollows = ballsalpha
		e.update = updateFunc
		e:register()
		components[math.floor((i-1)/40) + 1][((i-1) % 40) + 1] = e
	end
	local f = Formations.around:new{
		angle = 0,
		target = Vector:new{width/2, height/2},
		anglechange = Base.toRadians(20),
		distance = 80,
		adapt = false,
		speed = 1.1*v,
		shootattarget = true
	}
	f:applyOn(components[1])
	f.angle = 3*math.pi/2
	f:applyOn(components[2])
	f.anglechange = - f.anglechange
	f.angle = math.pi
	f:applyOn(components[3])
	f.angle = math.pi/2
	f:applyOn(components[4])

	self.shoottimer = Timer:new {
		timelimit = .5,
		works_on_gameLost = false,
		funcToCall = function()
			local e = self.getShot()
			e.position:set(self.position)
			local pos = psycho.position:clone()
			if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
			e.speed = (pos:sub(self.position)):normalize():add(random()/3, random()/3):normalize():mult(2 * v, 2 * v)
			e:register()
		end
	}

	Timer:new{
		timelimit = .2,
		running = true,
		funcToCall = function(timer)
			if components[1][40].inBox then
				timer:remove()
				self.visible = true
				self.alphaFollows:setAndGo(0, 255, 60)
				ballsalpha:setAndGo(255, 0, 30)
				ballsalpha.alsoCall = function(timer)
					timer.alsoCall = nil
					for i = 1, 4 do
						for _, b in ipairs(components[i]) do
							b.delete = true
						end
					end
					timer:new{timelimit = 1.2, onceOnly = true, running = true, funcToCall = function() 
						self.speed:set(v/7, 3*v)
						self.shoottimer:start()
						self.currentBehavior = bossLast.behaviors.first
					end}
				end
			end
		end
	}
end

local auxVec = Vector:new{}
local auxVec2 = Vector:new{}
local min, max = math.min, math.max
function bossLast:collidesWith( pos, size ) --rectangle with circle
	if not size then
		size = pos.size
		pos = pos.position
	end

	auxVec:set(pos):sub(self.position):rotate(-self.angle.var):add(self.position)
	auxVec2:set(
		max(min(auxVec[1], self.position[1] + self.width/2), self.position[1] - self.width/2),
		max(min(auxVec[2], self.position[2] + self.height/2), self.position[2] - self.height/2)
	)
	return Base.collides(auxVec, 0, auxVec2, size)
end
