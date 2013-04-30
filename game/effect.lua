require 'body'

effect = body:new {
	mode 	 = 'fill',
	size	 = 3,
	variance = 40,
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

function neweffects( position, times )
	for i=1,times do
		local e = effect:new{
			position = position:clone()
		}
		e.speed = vector:new {
			math.random(2.5*v)-1.25*v,
			math.random(2.5*v)-1.25*v
		}
		e.timetogo = math.random(50,130)/100
		e.etc = 0
		
		table.insert(effect.bodies,e)
	end
end