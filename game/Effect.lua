
Effect = Body:new {
	size	 = 1.7,
	__type   = 'Effect',
	spriteBatch = false,
	ord = 1,
	bodies = {}
}

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

local ceil, random = math.ceil, math.random
local effectCount = 0
function Effect.createEffects(based_on, times)
	times = ceil(times/2)
	--local speedinfluence = based_on.speed * .6
	if (based_on.alpha or (based_on.alphaFollows and based_on.alphaFollows.var) or 1) == 0 then return end
	if effectCount > 400 then Effect:handleTooMany(effectCount + times - 90) end
	effectCount = effectCount + times
	local effs = Effect.bodies
	for i = 1, times do
		local e = Effect:new{
			position = based_on.position + {based_on.size * (2 * random() - 1),based_on.size * (2 * random() - 1)},
			variance = based_on.variance,
			coloreffect = based_on.coloreffect,
			alpha = based_on.alpha,
			alphaFollows = based_on.alphaFollows,
			legit = true
		}

		e.speed:set(e.position):sub(based_on.position):normalize():mult(random() * v, random() * v)

		e.timetogo = random(300,1000) / 1000
		e:start()
		
		effs[#effs + 1] = e
	end
end

function Effect:handleDelete()
	if self.legit then effectCount = effectCount - 1 end
	Body.handleDelete(self)
end

function Effect:draw()
	local color = ColorManager.getComposedColor(self.variance, self.alphaFollows and self.alphaFollows.var or self.alpha, self.coloreffect)
	graphics.setColor(color)
	graphics.rectangle('fill', self.position[1], self.position[2], 2*self.size, 2*self.size)
end

function Effect:handleTooMany(n)
	local effs = Effect.bodies
	local num = 0
	for k, e in pairs(effs) do 
		num = num + 1
		if num == n then break end
		e:handleDelete()
		effs[k] = nil
	end
end