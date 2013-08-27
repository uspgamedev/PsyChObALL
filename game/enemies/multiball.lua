multiball = Body:new {
	size =  20,
	divideN = 2,
	args = {},
	coloreffect = ColorManager.ColorManager.getColorEffect(255, 0, 0),
	shader = base.circleShader,
	spriteBatch = graphics.newSpriteBatch(base.pixel, 250, 'dynamic'),
	spriteMaxNum = 250,
	spriteSafety = 10,
	__type = 'multiball'
}

Body.makeClass(multiball)

function multiball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
end

function multiball:update( dt )
	Body.update(self, dt)

	if self.position[1] < self.size or self.position[1] > width + self.size or self.position[2] < self.size or self.position[2] > width + self.size then return end
	for _, v in pairs(Shot.bodies) do
		if not v.collides and self:collidesWith(v) then
			self.collides = true
			v.collides = true
			v.explosionEffects = false
			self.diereason = "shot"
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function multiball:handleDelete()
	Body.handleDelete(self)
	neweffects(self, 20)
	if self.diereason ~= "shot" then return end
	addscore(50)
	--local ang = math.atan2(self.Vx, self.Vy)
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or enemies.simpleball):new(base.clone(self.args))
		e.size = self.size - 6
		e.position:set(self.position):add(math.random(self.size), math.random(self.size))
		e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
		if math.abs(e.Vy) + math.abs(e.Vx) then e.Vy = base.sign(self.Vy) * math.random(3 * v / 4, v) end
		e:register()
		--[[e.size = self.size - 10
		e.position:set(self.position)
		local angle = ang + (math.random() - .5)*base.toRadians(60)
		e.speed:set(math.sin(angle)*speed*1.3, math.cos(angle)*speed*1.3)
		e:register()]]
	end
end