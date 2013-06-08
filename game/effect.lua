effect = body:new {
	size	 = 3,
	__type   = 'effect',
	bodies = {}
}

function effect:draw()
	love.graphics.setColor(color(self.variance + colortimer.time))
	love.graphics.rectangle(self.mode, self.x, self.y, self.size, self.size)
end

function effect:update(dt)
	self.position:add(self.speed * dt)
	self.etc = self.etc + dt
	
	self.delete = self.etc > self.timetogo
end

function neweffects( based_on, times)
	local speedinfluence = based_on.speed * .6
	for i = 1,times do
		local e = effect:new{
			position = based_on.position + {based_on.size * (2 * math.random() - 1),based_on.size * (2 * math.random() - 1)},
			variance = based_on.variance
		}

		e.speed = (e.position - based_on.position):normalize():mult(math.random() * v, math.random() * v)

		e.timetogo = math.random(50,130) / 100
		e.etc = 0
		
		table.insert(effect.bodies, e)
	end
end