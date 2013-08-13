body = lux.object.new {
	size = 0,
	mode = 'fill',
	variance = 0,
	changesimage = true,
	__type = 'unnamed body'
}

function body:__init()
	self.position = rawget(self, 'position') or vector:new{}
	self.speed = rawget(self, 'speed') or vector:new{}
	self.__index = index
	self.__newindex = newindex
	
	if self.onInitInfo then
		self:onInit(unpack(self.onInitInfo))
		self.onInitInfo = nil
	else
		self:onInit()
	end
end

function index( self, key )
	if key == 'x'      then return self.position[1]
	elseif key == 'y'  then return self.position[2]
	elseif key == 'Vx' then return self.speed[1]
	elseif key == 'Vy' then return self.speed[2]
	else return getmetatable(self)[key] end
end

function newindex( self, key, v )
	if		 key == 'x' then  self.position[1] = v
	elseif key == 'y' then  self.position[2] = v
	elseif key == 'Vx' then self.speed[1] 	  = v
	elseif key == 'Vy' then self.speed[2] 	  = v
	else rawset(self, key, v) end
end

function body:update( dt )
	self.position:add(self.speed * dt)

	if (self.x + self.size < 0 and self.Vx <= 0) or (self.x > width + self.size and self.Vx >= 0) or
		(self.y + self.size < 0 and self.Vy <= 0) or (self.y > height + self.size and self.Vy >= 0) then
		self.delete = true
	end 
end

function body:draw()
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
	graphics.circle(self.mode, self.position[1], self.position[2], self.size)
end

function body:handleDelete()
	-- abstract
end

function body:onInit()
	-- abstract
end

function body:start()
	-- abstract
end

body.collidesWith = collides

function body:getWarning()
	self.warning = warning:new {
		based_on = self
	}
	warning.bodies[self] = self.warning
	return self.warning
end

function body:freeWarning()
	warning.bodies[self] = nil
	self.warning = nil
end

function body:paintOn( p )
	local m = {
		name = self.name,
		ord = self.ord or 5
	}
	m.__index = m
	setmetatable(self.bodies, m)
	table.insert(p, self.bodies)
end

function body:clear()
	cleartable(self.bodies)
end

function body:register(...)
	self:freeWarning()
	self:start(...)
	table.insert(self.bodies, self)
end