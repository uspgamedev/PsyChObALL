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
	--print(dt, self.var)
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

function vartimer:set( starts, ends )
	self.var = starts
	self.limit = ends
	self.backwards = ends < starts
end

function vartimer:setAndGo( ... )
	self:set(...)
	self:start()
end