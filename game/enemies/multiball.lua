multiball = Body:new {
	size =  20,
	divideN = 2,
	coloreffect = ColorManager.getColorEffect(255, 0, 0),
	shader = Base.circleShader,
	score = 50,
	__type = 'multiball'
}

Body.makeClass(multiball)

function multiball:revive()
	Body.revive(self)

	self.divideN = nil
	self.divideType = Enemies.simpleball

	return self
end

function multiball:update( dt )
	Enemies.simpleball.update(self, dt)
end

function multiball:manageShotCollision( shot )
	Enemies.simpleball.manageShotCollision(self, shot)
end

local random, abs = math.random, math.abs
function multiball:kill()
	Body.kill(self)

	Effect.createEffects(self, 20)

	if self.causeOfDeath ~= "shot" then return end

	local speed = self.speed:length()
	local objs = self.divideType.bodies:getObjects(self.divideN)
	for i = 1, self.divideN, 1 do
		local e = objs[i]:revive()
		if not self.score then e.score = false end
		e.size = self.size - 6
		e.position:set(self.position):add(random(self.size), random(self.size))
		e.speed:set(self.speed):add((random() - .5) * v * 1.9, (random() - .5) * v * 1.9):normalize():mult(v + 40 ,v + 40)
		if abs(e.Vy) + abs(e.Vx) < 40 then e.Vy = Base.sign(self.Vy) * random(3 * v / 4, v) end -- weird
		e:register()
	end
end