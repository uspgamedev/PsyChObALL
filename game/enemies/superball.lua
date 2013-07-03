module('enemies', package.seeall)

superball = body:new {
	size = 40,
	variance = 13,
	life = 60,
	__type = 'superball'
}

function superball:__init()
	if self.position:equals(-1, -1) then enemy.__init(self) end

	local vx, vy = math.random(v, v+50), math.random(v, v+50)
	vx = self.x < height/2 and vx or -vx
	vy = self.y < width/2 and vy or -vy
	self.speed	  = vector:new {vx, vy}

	self.shoottimer = timer:new {
		timelimit = 1.7,
		works_on_gamelost = false,
		time = math.random()*1.6
	}

	function self.shoottimer.funcToCall()
		local e = state == survival and enemy:new{} or enemies.newsimpleball{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():mult(2 * v, 2 * v)
		table.insert(state == survival and enemy.bodies or paintables.simpleball,e)
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

function superball:start()
	self.shoottimer:start()
	self.speedtimer:start()
	table.insert(circleEffect.bodies, self.lifeCircle)
end

function superball:update(dt)
	body.update(self, dt)
	if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end

	for i,v in pairs(shot.bodies) do
		if (v.size + self.lifeCircle.size) * (v.size + self.lifeCircle.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
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

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end
end

function superball:handleDelete()
	neweffects(self,100)
	self.lifeCircle.size = -1
	self.shoottimer:stop()
	self.shoottimer.delete = true
	self.speedtimer:stop()
	self.speedtimer.delete = true
end