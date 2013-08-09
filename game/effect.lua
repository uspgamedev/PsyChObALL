effect = body:new {
	size	 = 3,
	__type   = 'effect',
	bodies = {}
}

function effect:draw()
	graphics.setColor(color(self.variance + colortimer.time, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.rectangle(self.mode, self.x, self.y, self.size, self.size)
end

function effect:update(dt)
	self.position:add(self.speed * dt)
	self.etc = self.etc + dt
	
	self.delete = self.etc > self.timetogo
end

function neweffects( based_on, times)
	--local speedinfluence = based_on.speed * .6
	if #effect.bodies > 1000 then 
		local n = #effect.bodies
		for i = 0, 200 do
			effect.bodies[math.random(n)] = nil
		end
	end
	for i = 1,times do
		local e = effect:new{
			position = based_on.position + {based_on.size * (2 * math.random() - 1),based_on.size * (2 * math.random() - 1)},
			variance = based_on.variance,
			coloreffect = based_on.coloreffect,
			alpha = based_on.alpha,
			alphafollows = based_on.alphafollows
		}

		e.speed = (e.position - based_on.position):normalize():mult(math.random() * v, math.random() * v)

		e.timetogo = math.random(50,130) / 100
		e.etc = 0
		
		table.insert(effect.bodies, e)
	end
end