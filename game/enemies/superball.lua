module('enemies', package.seeall)

superball = body:new {
	size = 40,
	variance = 13,
	life = 60,
	ord = 6,
	__type = 'superball'
}

function superball:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end

	local vx, vy = math.random(v, v+50), math.random(v, v+50)
	vx = self.x < height/2 and vx or -vx
	vy = self.y < width/2 and vy or -vy
	self.speed	  = vector:new {vx, vy}

	self.shoottimer = timer:new {
		timelimit = 1.5 + math.random(),
		works_on_gamelost = false,
		time = math.random()*1.6
	}

	function self.shoottimer.funcToCall( timer )
		timer.timelimit = 1 + math.random()
		local e = self.shot:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():add(math.random()/3, math.random()/3):normalize():mult(2 * v, 2 * v)
		e:register(self.extra and unpack(self.extra) or nil)
	end

	self.speedtimer = timer:new {
		timelimit = math.random()*4 + 1
	}

	function self.speedtimer.funcToCall(timer)
		timer.timelimit = math.random()*3 + 1
		local vx, vy = math.random(-50, 50), math.random(-50, 50)
		vx = vx + v*sign(vx)
		vy = vy + v*sign(vy)
		self.speed:set(vx, vy)
	end

	self.lifeCircle = circleEffect:new {
		alpha = 60,
		sizeGrowth = 0,
		size = self.size + self.life,
		position = self.position,
		index = false,
		linewidth = 6
	}
end

function superball:onInit( shot, ... )
	self.shot = shot and enemies[shot] or state == survival and enemy or enemies.simpleball
	self.extra = select('#', ...) > 0 and {...} or nil
end

function superball:start( shot )
	self.shoottimer:start()
	self.speedtimer:start()
	self.lifeCircle.position = self.position
	self.lifeCircle:register()
end

function superball:update(dt)
	body.update(self, dt)
	if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end

	for i,v in pairs(shot.bodies) do
		if (v.size + self.lifeCircle.size)^2 >= (v.x - self.x)^2 + (v.y - self.y)^2 then
			v.collides = true
			v.explosionEffects = false
			local bakvariance = v.variance
			v.variance = self.variance
			neweffects(v,10)
			v.variance = bakvariance
			self.life = self.life - 4
			self.lifeCircle.size = self.size + self.life
			if self.life <= 0 then 
				self.delete = true
				break
			end
		end
	end

	if psycho.canbehit and not gamelost and (psycho.size + self.size)^2 >= (psycho.x - self.x)^2 + (psycho.y - self.y)^2 then
		psycho.diereason = "shot"
		lostgame()
	end
end

function superball:handleDelete()
	neweffects(self,100)
	self.lifeCircle.sizeGrowth = -300
	self.shoottimer:remove()
	self.shoottimer.delete = true
	self.speedtimer:remove()
	self.speedtimer.delete = true
end