--use this to change variables with time
vartimer = timer:new {
	persistent = true,
	var = 0,
	limit = 100,
	backwards = false,
	speed = 100,
	pausable = false
}

function vartimer:funcToCall( dt )
	if self.backwards then
		if self.limit < self.var then 
			self.var = math.max(self.limit, self.var - self.speed*dt)
		else
			self:stop()
		end
	else
		if self.limit > self.var then 
			self.var = math.min(self.limit, self.var + self.speed*dt)
		else
			self:stop()
		end
	end
end

function vartimer:set( starts, ends, speed )
	self.var = starts or self.var
	self.limit = ends or self.limit
	self.backwards = self.limit < self.var
	self.speed = speed or self.speed
end

function vartimer:setAndGo( ... )
	self:set(...)
	self:start()
end