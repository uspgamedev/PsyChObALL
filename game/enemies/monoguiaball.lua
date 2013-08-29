monoguiaball = Body:new {
	size =  25,
	divideN = 3,
	args = {},
	coloreffect = ColorManager.ColorManager.getColorEffect(20, 140, 0),
	spriteBatch = graphics.newSpriteBatch(base.pixel, 150, 'dynamic'),
	spriteMaxNum = 150,
	spriteSafety = 10,
	shader = base.circleShader,
	__type = 'monoguiaball'
}

Body.makeClass(monoguiaball)

function monoguiaball:__init()
	if not rawget(self.position, 1) then Enemy.__init(self) end
end

function monoguiaball:update( dt )
	Body.update(self, dt)

	for _, v in pairs(Shot.bodies) do
		if not v.collides and self:collidesWith(v) then
			self:manageShotCollision(v)
			break
		end
	end

	if psycho.canbehit and not gamelost and self:collidesWith(psycho) then
		psycho.diereason = "shot"
		lostgame()
	end

	self.delete = self.delete or self.collides
end

function monoguiaball:manageShotCollision( shot )
	shot.collides = true
	shot.explosionEffects = false
	self.collides = true
	self.diereason = shot.isUltraShot and 'ultrashot' or 'shot'
end

function monoguiaball:handleDelete()
	Body.handleDelete(self)
	neweffects(self, 20)
	if self.diereason ~= "shot" then return end
	addscore(100)
	local speed = self.speed:length()
	for i = 1, self.divideN do
		local e = (self.divideType or enemies.multiball):new(lux.object.clone(self.args))
		e.size = self.size - 6
		e.position:set(self.position):add(math.random(self.size), math.random(self.size))
		e.speed:set(self.speed):add((math.random() - .5)*v*1.9, (math.random() - .5)*v*1.9):normalize():mult(v + 40 ,v + 40)
		if math.abs(e.Vy) + math.abs(e.Vx) < 40 then e.Vy = base.sign(self.Vy) * math.random(3 * v / 4, v) end
		e:register()
	end
end