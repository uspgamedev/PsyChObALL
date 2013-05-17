require 'body'

boss = body:new {
	size = 40,
	variance = 13,
	life = 60,
	lifecolor = {0,0,0,0},
	__type = 'boss'
}

function boss:__init()
	self.position = vector:new {50, 50}

	local vx, vy = math.random(-50, 50), math.random(-50, 50)
	vx = vx + v*signum(vx)
	vy = vy + v*signum(vy)
	self.speed	  = vector:new {vx, vy}

	self.shoottimer = timer:new {
		timelimit = 1,
		works_on_gamelost = false
	}

	function self.shoottimer.funcToCall()
		local e = enemy:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = (pos:sub(self.position)):normalize():mult(2 * v, 2 * v)
		table.insert(enemy.bodies,e)
	end

	self.speedtimer = timer:new {
		timelimit = math.random()*3 + 1
	}

	function self.speedtimer.funcToCall(timer)
		timer.timelimit = math.random()*3 + 1
		local vx, vy = math.random(-50, 50), math.random(-50, 50)
		vx = vx + v*signum(vx)
		vy = vy + v*signum(vy)
		self.speed:set(vx, vy)
	end

	self.lifeCircle = circleEffect:new {
		alpha = 30,
		sizeGrowth = 0,
		size = self.size + self.life,
		position = self.position,
		linewidth = 6
	}
end

function boss:draw()
	graphics.setColor(color(self.color, self.variance + colortimer.time))
	graphics.circle(self.mode, self.x, self.y, self.size)
	graphics.setColor(color(self.lifecolor, self.variance + 3 + colortimer.time))
	self.lifeCircle:draw()
end

function boss:update(dt)
	boss:__super().update(self, dt)
	if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
	elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

	if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
	elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
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

function boss:handleDelete()
	neweffects(self,100)
end