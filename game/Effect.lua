local Body = Body
local baseSpeed = Base.gameSpeed
local ceil, random = math.ceil, math.random
local Effect = Body:new {
	size	 = 1.7,
	__type   = 'Effect',
	spriteBatch = graphics.newSpriteBatch(Base.pixel, 1000, 'dynamic'),
	spriteMaxNum = 1000,
	spriteCount = 0,
	bodies = {}
}
setfenv(1, {})

Body.makeClass(Effect)

function Effect:start()
	Body.start(self)
	self.etc = 0
end

function Effect:update(dt)
	Body.update(self, dt)
	self.etc = self.etc + dt

	self.delete = self.delete or self.etc > self.timetogo
end

function Effect.createEffects(based_on, times)
	times = ceil(times/2)
	--local speedinfluence = based_on.speed * .6
	if (based_on.alpha or (based_on.alphaFollows and based_on.alphaFollows.var) or 1) == 0 then return end
	for i = 1, times do
		local e = Effect:new{
			position = based_on.position + {based_on.size * (2 * random() - 1),based_on.size * (2 * random() - 1)},
			variance = based_on.variance,
			coloreffect = based_on.coloreffect,
			alpha = based_on.alpha,
			alphaFollows = based_on.alphaFollows
		}

		e.speed:set(e.position):sub(based_on.position):normalize():mult(random() * baseSpeed, random() * baseSpeed)

		e.timetogo = random(50,130) / 100
		e:start()
		
		Effect.bodies[#Effect.bodies + 1] = e
	end
end

return Effect