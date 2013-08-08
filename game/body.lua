require 'lux.object'
require 'vector'

body = lux.object.new {
	size = 0,
	mode = 'fill',
	dead = false,
	variance = 0,
	changesimage = true,
	__type = 'unnamed body'
}


function body:__init()
	self.position = self.position or vector:new{}
	self.speed = self.speed or vector:new{}
	function self:__index( key )
		if key == 'x' then return self.position[1]
		elseif key == 'y' then return self.position[2]
		elseif key == 'Vx' then return self.speed[1]
		elseif key == 'Vy' then return self.speed[2]
		else return getmetatable(self)[key] end
	end

	function self:__newindex( key, v )
		if		 key == 'x' then  self.position[1] = v
		elseif key == 'y' then  self.position[2] = v
		elseif key == 'Vx' then self.speed[1] 	 = v
		elseif key == 'Vy' then self.speed[2] 	 = v
		else rawset(self, key, v) end
	end
	self:onInit(self.onInitInfo and unpack(self.onInitInfo))
	if self.onInitInfo then
		self.onInitInfo = nil
	end
end

function body:update( dt )
	self.position:add(self.speed * dt)

	if (self.x + self.size < 0 and self.Vx <= 0) or (self.x > width + self.size and self.Vx >= 0) or
		(self.y + self.size < 0 and self.Vy <= 0) or (self.y > height + self.size and self.Vy >= 0) then
		self.delete = true
	end 
end

function body:draw()
	if self.changesimage and cheats.image.enabled then
		if cheats.image.painted then graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var, self.coloreffect))
		else graphics.setColor(255,255,255) end
		if self.stencil then graphics.setStencil(self.stencil) end
		graphics.draw(cheats.image.image, self.position[1] - self.size, self.position[2] - self.size, 0, 2*self.size / cheats.image.image:getWidth(), 2*self.size / cheats.image.image:getHeight())
		if self.stencil then graphics.setStencil() end
		return
	end
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