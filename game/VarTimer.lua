--use this to change variables with time
VarTimer = Timer:new {
	persistent = true,
	var = 0,
	limit = 100,
	backwards = false,
	speed = 100,
	pausable = true
}

function VarTimer:__init()
	Timer.__init(self)
	if self[1] then
		self.var = self[1]
		self[1] = nil
	end
end

function VarTimer:funcToCall( dt )
	if self.backwards then
		self.var = self.var - self.speed * dt
		if self.var <= self.limit then 
			self.var = self.limit
			self:stop()
			if self.alsoCall then self:alsoCall() end
		end
	else
		self.var = self.var + self.speed * dt
		if self.var >= self.limit then 
			self.var = self.limit
			self:stop()
			if self.alsoCall then self:alsoCall() end
		end
	end
end

function VarTimer:set( starts, ends, speed )
	self.var = starts or self.var
	self.limit = ends or self.limit
	self.backwards = self.limit < self.var
	self.speed = speed or self.speed
end

function VarTimer:setAndGo( ... )
	self:set(...)
	self:start()
end