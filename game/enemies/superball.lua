superball = Body:new {
	size = 40,
	variance = 13,
	life = 60,
	timeout = 40,
	collides = true,
	shader = Base.circleShader,
	spriteBatch = false,
	ord = 6,
	__type = 'superball'
}

Body.makeClass(superball)

function superball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end

	local vx, vy = math.random(v, v+50), math.random(v, v+50)
	vx = self.x < height/2 and vx or -vx
	vy = self.y < width/2 and vy or -vy
	self.speed	  = Vector:new {vx, vy}

	self.coloreffect = self.shot.coloreffect
	self.variance = self.shot.variance

	self.shoottimer = Timer:new {
		timelimit = 1.5 + math.random(),
		works_on_gameLost = false,
		time = math.random()*1.6
	}

	function self.shoottimer.funcToCall(timer )
		timer.timelimit = 1 + math.random()
		local e = self.shot:new{}
		e.position = self.position:clone()
		local pos = psycho.position:clone()
		if not psycho.speed:equals(0, 0) then pos:add(psycho.speed:normalized():mult(v / 2, v / 2)) end
		e.speed = pos:sub(self.position):normalize():mult(1.5 * v, 1.5 * v):rotate((math.random()-.5)*Base.toRadians(30))
		e:register(self.extra and unpack(self.extra) or nil)
	end

	if state == survival then 
		self.speedtimer = Timer:new {
			timelimit = math.random()*4 + 1
		}

		function self.speedtimer.funcToCall(timer)
			timer.timelimit = math.random()*3 + 1
			local vx, vy = math.random(-50, 50), math.random(-50, 50)
			vx = vx + v*Base.sign(vx)
			vy = vy + v*Base.sign(vy)
			self.speed:set(vx, vy)
		end
	end

	self.lifeCircle = CircleEffect:new {
		alpha = 60,
		sizeGrowth = 0,
		size = self.size + self.life,
		position = self.position,
		index = false,
		linewidth = 6
	}

	self.timeout = Timer:new {
		timelimit = self.timeout,
		onceonly = true,
		funcToCall = function()
			self.collides = false
			self.speed:set(self.exitposition):sub(self.position):normalize():mult(1.1*v, 1.1*v)
		end
	}
end

function superball:onInit( shot, exitpos, timeout, ... )
	self.shot = shot and Enemies[shot] or state == survival and Enemy or Enemies.simpleball
	self.timeout = timeout
	self.exitposition = self.exitposition or Base.clone(exitpos) or Base.clone(self.position)
	self.extra = select('#', ...) > 0 and {...} or nil
end

function superball:start( shot )
	Body.start(self)
	self.healthbak = self.life
	self.lifeCircle.size = self.size + self.life
	self.shoottimer:start()
	self.timeout:start()
	if state == survival then self.speedtimer:start() end
	self.lifeCircle.position = self.position
	self.lifeCircle:register()
end

superball.draw = Base.defaultDraw

function superball:update(dt)
	Body.update(self, dt)
	if self.collides then
		if self.x  + self.size > width then self.speed:set(-math.abs(self.Vx))
		elseif self.x - self.size < 0  then self.speed:set( math.abs(self.Vx)) end

		if self.y + self.size > height then self.speed:set(nil, -math.abs(self.Vy))
		elseif self.y - self.size < 0  then self.speed:set(nil,  math.abs(self.Vy)) end
	end

	for _, v in pairs(Shot.bodies) do
		if Base.collides(v.position, v.size, self.position, self.lifeCircle.size) then
			self:manageShotCollision(v)
			break
		end
	end

	if psycho.canbehit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end
end

function superball:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	local bakvariance = shot.variance
	shot.variance = self.variance
	neweffects(shot,10)
	shot.variance = bakvariance
	self.life = self.life - 4
	self.lifeCircle.size = self.size + self.life
	if self.life <= 0 then
		self.diereason = shot.isUltraShot and 'ultrashot' or 'shot'
		self.delete = true
	end
end

function superball:handleDelete()
	Body.handleDelete(self)
	if self.diereason == 'shot' then addscore(4*self.healthbak + 2*self.size) end
	neweffects(self,100)
	self.lifeCircle.sizeGrowth = -300
	self.shoottimer:remove()
	self.timeout:remove()
	if state == survival then self.speedtimer:remove() end
end