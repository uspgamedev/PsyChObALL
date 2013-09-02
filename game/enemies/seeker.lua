seeker = Body:new {
	size = 20,
	timeout = 10,
	seek = true,
	health = 10,
	spriteBatch = false,
	shader = base.circleShader,
	__type = 'seeker'
}

Body.makeClass(seeker)

function seeker:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
	self.speedN = self.speedN or math.random(v - 30, v)
	self.exitposition = self.exitposition or self.position
	self.colors = {VarTimer:new{var = .88*255}, VarTimer:new{var = .66*255}, VarTimer:new{var = .37*255}}
	self.coloreffect = ColorManager.ColorManager.getColorEffect(unpack(self.colors))
	self.acceleration = Vector:new{0, 0}
end

function seeker:start()
	Body.start(self)
	self.timeout = Timer:new{
		timelimit = self.timeout,
		onceonly = true,
		running = true,
		funcToCall = function()
			self.seek = false
			self.speed:set(self.exitposition):sub(self.position):normalize():mult(self.speedN)
			self.acceleration:set(0,0)
		end
	}
end

seeker.draw = base.defaultDraw

local auxVec = Vector:new{}
function seeker:update( dt )
	for _, sek in pairs(seeker.bodies) do
		if sek ~= self then
			auxVec:set(sek.position):sub(self.position)
			local len = auxVec:length()
			if len < 200 then
				auxVec:mult((200 - len)/len):mult(25)
				sek.acceleration:add(auxVec)
			end
		end
	end

	if self.seek then
		auxVec:set(psycho.position):sub(self.position)
		local len = math.min(auxVec:length(), 300)
		auxVec:mult((400 - len)/len):mult(60)
		self.acceleration:add(auxVec)
		self.speed:add(auxVec:set(self.acceleration):mult(dt))
		self.acceleration:set(0, 0)
		
		local spd = self.speed:length()
		if spd > self.speedN then
			self.speed:mult(self.speedN/spd)
		end
		self.position:add(auxVec:set(self.speed):mult(dt))
	else
		Body.update(self, dt)
	end

	for _, v in pairs(Shot.bodies) do
		if not v.collides and self:collidesWith(v) then
			self:manageShotCollision(v)
			break
		end
		if self.seek then
			auxVec:set(self.position):sub(v.position)
			local len = auxVec:length()
			if len < 200 then
				len = math.max(len, 20)
				auxVec:mult((200 - len)/len):mult(80)
				self.acceleration:add(auxVec)
			end
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function seeker:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	self.health = self.health - 1
	if self.health == 0 then
		self.collides = true
		self.diereason = "shot"
	end
	local d = self.health/seeker.health
	self.colors[1]:setAndGo(nil, .88*255 + (1-d)*.22*255, 30)
	self.colors[2]:setAndGo(nil, .66*255*d, 30)
	self.colors[3]:setAndGo(nil, .37*255*d, 30)
end

function seeker:onInit( timeout, exitpos )
	self.timeout = timeout
	self.exitposition = base.clone(exitpos)
end

function seeker:handleDelete()
	Body.handleDelete(self)
	if self.diereason == 'shot'then addscore(100) end
	neweffects(self, 40)
end