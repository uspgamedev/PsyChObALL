module("effect",package.seeall) do
	local Effect = {}
	Effect.__index = Effect
	
	function Effect:draw()
		love.graphics.rectangle("fill",self.x,self.y,self.size,self.size)
	end
	
	function Effect:update(dt)
		self.x = self.x + self.Vx*dt
		self.y = self.y + self.Vy*dt
		self.etc = self.etc + dt
		return self.etc<self.timetogo
	end
	
	function Effect:handleDelete()
		
	end
	
	function new(x,y,times,t)
		for i=1,times do
			local effect = {}
			setmetatable(effect,Effect)
			effect.x = x
			effect.y = y
			effect.Vx = math.random(2.5*v)-1.25*v
			effect.Vy = math.random(2.5*v)-1.25*v
			effect.typ = "effect"
			effect.size = 3
			effect.timetogo = math.random(50,130)/100
			effect.etc = 0
			
			table.insert(t,effect)
		end
	end
end