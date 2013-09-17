-- dependencies
local lux, graphics = lux, graphics
local rawget, rawset, unpack, getmetatable, pairs = rawget, rawset, unpack, getmetatable, pairs
local width, height = width, height
local Base, Vector, ColorManager = Base, Vector, ColorManager
local global = _G
local Body
setfenv(1, {})

Body = lux.object.new {
	size = 0,
	mode = 'fill',
	variance = 0,
	changesimage = true,
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
	if subclass.spriteBatch == nil then
		subclass.spriteBatch = graphics.newSpriteBatch(Base.pixel, 200, 'dynamic')
		subclass.spriteMaxNum = 200
	end
	if subclass.spriteBatch then
		subclass.spriteCount = 0

	end
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
	local color = ColorManager.getComposedColor(self.variance, self.alphaFollows and self.alphaFollows.var or self.alpha, self.coloreffect)
	self.spriteBatch:setColor(unpack(color))
	self.spriteBatch:set(self.id, self.position[1] - self.size, self.position[2] - self.size, 0, 2*self.size)
end

function Body:handleDelete()
	if self.spriteBatch then
		self.spriteBatch:set(self.id, 0, 0, 0, 0, 0) 
	end
end

function Body:onInit()
	-- abstract
end

function Body:start()
	if self.spriteBatch then self:addToBatch() end
end

function Body:addToBatch()
	if self.spriteBatch then
		if self.spriteCount > self.spriteMaxNum - (self.spriteSafety or 10) then
			self:__super().spriteCount = 1
			self.spriteBatch:bind()
			self.spriteBatch:clear()
			self.id = self.spriteBatch:add(self.position[1] - self.size, self.position[2] - self.size, 0, 2*self.size)
			for _, p in pairs(self.bodies) do p:addToBatch() end
			self.spriteBatch:unbind()
		else
			self.id = self.spriteBatch:add(self.position[1] - self.size, self.position[2] - self.size, 0, 2*self.size)
			self:__super().spriteCount = self:__super().spriteCount + 1
		end
	end
end

Body.collidesWith = Base.collides

function Body:getWarning()
	self.warning = global.Warning:new {
		based_on = self
	}
	global.Warning.bodies[self] = self.warning
	return self.warning
end

function Body:freeWarning()
	global.Warning.bodies[self] = nil
	self.warning = nil
end

function Body:paintOn( p )
	p[#p + 1] = self
end

function Body:drawComponents()
	if self.shader then graphics.setPixelEffect(self.shader) end
	if self.spriteBatch then self.spriteBatch:bind() end
	for _, body in pairs(self.bodies) do
		body:draw()
	end
	if self.spriteBatch then self.spriteBatch:unbind()	graphics.draw(self.spriteBatch, 0, 0) end
	if self.shader then graphics.setPixelEffect() end
end

local todelete = {}
function Body:updateComponents( dt )
	for k, body in pairs(self.bodies) do
		body:update(dt)
		if body.delete then
			todelete[#todelete + 1] = k
		end
	end

	local n
	for k = #todelete, 1, -1 do
		n = todelete[k]
		self.bodies[n]:handleDelete()
		self.bodies[n] = nil
		todelete[k] = nil
	end
end

function Body:clear()
	for k, b in pairs(self.bodies) do
		Body.handleDelete(b)
		self.bodies[k] = nil
	end
end

function Body:register(...)
	self:freeWarning()
	self:start(...)
	self.bodies[#self.bodies + 1] = self
	if self.positionfollows then
		self.initialtime = gametime
		self.initialpos  = self.position:clone()
	end
end

return Body