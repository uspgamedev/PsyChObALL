require 'base.Basic'
require 'base.Group'

Body = Basic:new {
	size = 0,
	mode = 'fill',
	variance = 0,
	positionfollows = nil, --function
	ord = 5,
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
	if rawget(subclass, 'bodies') then
		subclass.bodies.class = subclass
	end
end

function Body:update( dt )
	if self.positionfollows then
		self.position:set(self.positionfollows(RecordsManager.getGameTime() - self.initialtime)):add(self.initialpos)
	else
		self.position:add(auxVec:set(self.speed):mult(dt))
	end

	if (self.x + self.size < 0 and self.Vx <= 0) or (self.x > width + self.size and self.Vx >= 0) or
		(self.y + self.size < 0 and self.Vy <= 0) or (self.y > height + self.size and self.Vy >= 0) then
		self:kill()
	end 
end

function Body:draw()
	if self.linewidth then graphics.setLineWidth(self.linewidth) end
	Base.defaultDraw(self)
end

function Body:handleDelete()
	if self.score and self.causeOfDeath == 'shot' then RecordsManager.addScore(self.score) end
end

function Body:onInit()
	-- abstract
end

function Body:start()

end

Body.collidesWith = Base.collides

function Body:getWarning()
	if self.warning then self:freeWarning() end
	self.warning = Warning.bodies:getFirstAvailable():revive(self)
	return self.warning
end

function Body:freeWarning()
	if self.warning then
		self.warning:kill()
		self.warning = nil
	end
end

function Body:paintOn( p )
	table.insert(p, self)
end

function Body:drawComponents()
	if not self.bodies.draw then return end -- temporary
	if self.shader and not Cheats.image.enabled then graphics.setPixelEffect(self.shader) end
	self.bodies:draw()
	if self.shader and not Cheats.image.enabled then graphics.setPixelEffect() end
end

function Body:updateComponents( dt )
	if not self.bodies.update then return end -- temporary
	self.bodies:update(dt)
end

function Body:clear()
	self.bodies:clearAll()
end

function Body:register(...)
	self:freeWarning()
	self:start(...)
	if self.positionfollows then
		self.initialtime = RecordsManager.getGameTime()
		self.initialpos  = self.position:clone()
	end
end