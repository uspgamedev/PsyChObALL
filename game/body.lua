Body = lux.object.new {
	size = 0,
	mode = 'fill',
	variance = 0,
	changesimage = true,
	positionfollows = nil, --function
	__type = 'unnamed Body'
}

local auxVec = Vector:new{}

function Body:__init()
	self.position = rawget(self, 'position') or Vector:new{}
	self.speed = rawget(self, 'speed') or Vector:new{}
	
	if self.onInitInfo then
		self:onInit(unpack(self.onInitInfo))
		self.onInitInfo = nil
	else
		self:onInit()
	end
end

local function index( self, key )
	if key == 'x'      then return self.position[1]
	elseif key == 'y'  then return self.position[2]
	elseif key == 'Vx' then return self.speed[1]
	elseif key == 'Vy' then return self.speed[2]
	else return getmetatable(self)[key] end
end

local function newindex( self, key, v )
	if		 key == 'x' then  self.position[1] = v
	elseif key == 'y' then  self.position[2] = v
	elseif key == 'Vx' then self.speed[1] 	  = v
	elseif key == 'Vy' then self.speed[2] 	  = v
	else rawset(self, key, v) end
end

function Body.makeClass( subclass )
	subclass.__newindex = newindex
	subclass.__index = index
end

function Body:update( dt )
	if self.positionfollows then
		self.position:set(self.positionfollows(gametime - self.initialtime)):add(self.initialpos)
	else
		self.position:add(auxVec:set(self.speed):mult(dt))
	end

	if (self.x + self.size < 0 and self.Vx <= 0) or (self.x > width + self.size and self.Vx >= 0) or
		(self.y + self.size < 0 and self.Vy <= 0) or (self.y > height + self.size and self.Vy >= 0) then
		self.delete = true
	end 
end

function Body:draw()
	if self.linewidth then graphics.setLineWidth(self.linewidth) end
	local color = ColorManager.getComposedColor(ColorManager.timer.time + self.variance, self.alphafollows and self.alphafollows.var or self.alpha, self.coloreffect)
	graphics.setColor(color)
	graphics.circle(self.mode, self.position[1], self.position[2], self.size)
end

function Body:handleDelete()

end

function Body:onInit()
	-- abstract
end

function Body:start()
	
end

Body.collidesWith = base.collides

function Body:getWarning()
	self.warning = Warning:new {
		based_on = self
	}
	Warning.bodies[self] = self.warning
	return self.warning
end

function Body:freeWarning()
	Warning.bodies[self] = nil
	self.warning = nil
end

function Body:paintOn( p )
	local m = {
		name = self.name,
		ord = self.ord or 5,
		noShader = self.noShader
	}
	m.__index = m
	setmetatable(self.bodies, m)
	table.insert(p, self.bodies)
end

function Body:clear()
	base.clearTable(self.bodies)
end

function Body:register(...)
	self:freeWarning()
	self:start(...)
	table.insert(self.bodies, self)
	if self.positionfollows then
		self.initialtime = gametime
		self.initialpos  = self.position:clone()
	end
end