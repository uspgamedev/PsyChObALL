seeker = body:new {
	size = 20,
	timeout = 10,
	seek = true,
	health = 10,
	__type = 'seeker'
}

function seeker:__init()
	if not rawget(self.position, 1) then enemy.__init(self) end
	self.speedN = self.speedN or math.random(v - 30, v)
	self.exitposition = self.exitposition or self.position
	self.colors = {vartimer:new{var = .88*255}, vartimer:new{var = .66*255}, vartimer:new{var = .37*255}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(unpack(self.colors))
end

function seeker:start()
	body.start(self)
	self.timeout = timer:new{
		timelimit = self.timeout,
		onceonly = true,
		running = true,
		funcToCall = function()
			self.seek = false
			self.speed:set(self.exitposition):sub(self.position):normalize():mult(self.speedN)
		end
	}
end

function seeker:update( dt )
	if self.seek then
		self.speed:set(psycho.position):sub(self.position):normalize():mult(self.speedN, self.speedN)
	end
	body.update(self, dt)

	for _, v in pairs(shot.bodies) do
		if not v.collides and self:collidesWith(v) then
			v.collides = true
			v.explosionEffects = false
			self.health = self.health - 1
			if self.health == 0 then
				self.collides = true
				self.diereason = "shot"
			end
			local d = self.health/seeker.health
			self.colors[1]:setAndGo(nil, .88*255 + (1-d)*.22*255, 30)
			self.colors[2]:setAndGo(nil, .66*255*d, 30)
			self.colors[3]:setAndGo(nil, .37*255*d, 30)
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function seeker:onInit( timeout, exitpos )
	self.timeout = timeout
	self.exitposition = clone(exitpos)
end

function seeker:handleDelete()
	body.handleDelete(self)
	if self.diereason == 'shot'then addscore(100) end
	neweffects(self, 40)
end