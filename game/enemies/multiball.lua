multiball = body:new {
	size =  20,
	divideN = 2,
	angleBetween = torad(30),
	args = {},
	__init = enemy.__init,
	__type = 'multiball'
}

function multiball:update( dt )
	body.update(self, dt)

	for i,v in pairs(shot.bodies) do
		if (v.size + self.size) * (v.size + self.size) >= (v.x - self.x) * (v.x - self.x) + (v.y - self.y) * (v.y - self.y) then
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
	local ang = math.atan(self.Vx/self.Vy) --+ self.Vy < 0 and math.pi or 0
	ang = ang - self.angleBetween*self.divideN/2
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or enemies.simpleball):new(lux.object.clone(self.args))
		e.position:set(self.position:clone())
		e.speed:set(math.sin(ang)*speed, math.cos(ang)*speed)
		e:register()
		ang = ang + self.angleBetween
	end
end