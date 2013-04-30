require 'body'

effect = body:new {
	mode 	 = 'fill',
	size	 = 3,
	__type   = 'effect'
}

function effect:draw()
	love.graphics.setColor(color(self.variance + colortimer.time))
	love.graphics.rectangle(self.mode,self.x,self.y,self.size,self.size)
end

function effect:update(dt)
	self.position:add(self.speed*dt)
	self.etc = self.etc + dt
	return self.etc<self.timetogo
end

function neweffects( position, times, var )
	local variance = var or colortimer.timelimit*math.random()*2
	for i=1,times do
		local e = effect:new{
			position = position:clone(),
			variance = variance
		}
		e.speed = vector:new {
			math.random()*2 - 1,
			math.random()*2 - 1
		}:mult(v,v)
		e.timetogo = math.random(50,130)/100
		e.etc = 0
		
		table.insert(effect.bodies,e)
	end
end