multiball = Body:new {
	size =  20,
	divideN = 2,
	args = {},
	coloreffect = ColorManager.ColorManager.getColorEffect(255, 0, 0),
	shader = Base.circleShader,
	spriteBatch = graphics.newSpriteBatch(Base.pixel, 250, 'dynamic'),
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

	if self.position[1] < -self.size or self.position[1] > width + self.size or self.position[2] < -self.size or self.position[2] > width + self.size then return end
	for _, v in pairs(Shot.bodies) do
		if self:collidesWith(v) then
			self:manageShotCollision(v)
			break
		end
	end

	if psycho.canBeHit and not DeathManager.gameLost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		DeathManager.manageDeath()
	end

	self.delete = self.delete or self.collides
end

function multiball:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	self.collides = true
	self.diereason = shot.isUltraShot and 'ultrashot' or 'shot'
end

function multiball:handleDelete()
	Body.handleDelete(self)
	neweffects(self, 20)
	if self.diereason ~= "shot" then return end
	addscore(50)
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or Enemies.simpleball):new(lux.object.clone(self.args))
		e.size = self.size - 6
		e.position:set(self.position):add(math.random(self.size), math.random(self.size))
		e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
		if math.abs(e.Vy) + math.abs(e.Vx) then e.Vy = Base.sign(self.Vy) * math.random(3 * v / 4, v) end
		e:register()
	end
end