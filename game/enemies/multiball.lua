multiball = body:new {
	size =  20,
	divideN = 2,
	args = {},
	coloreffect = getColorEffect(255, 0, 0),
	__init = enemy.__init,
	__type = 'multiball'
}

function multiball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if not v.collides and (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if not gamelost and (psycho.size + self.size) * (psycho.size + self.size) >= (psycho.x - self.x) * (psycho.x - self.x) + (psycho.y - self.y) * (psycho.y - self.y) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function multiball:handleDelete()
	neweffects(self, 20)
	if self.diereason ~= "shot" then return end
	--local ang = math.atan2(self.Vx, self.Vy)
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or enemies.simpleball):new(lux.object.clone(self.args))
		e.size = self.size - 6
		e.position:set(self.position):add(math.random(self.size), math.random(self.size))
		e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
		if e.Vy + e.Vx < 40 then e.Vy = sign(self.Vy) * math.random(3 * v / 4, v) end
		e:register()
		--[[e.size = self.size - 10
		e.position:set(self.position)
		local angle = ang + (math.random() - .5)*torad(60)
		e.speed:set(math.sin(angle)*speed*1.3, math.cos(angle)*speed*1.3)
		e:register()]]
	end
end