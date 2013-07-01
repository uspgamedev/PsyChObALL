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

body.__init = {
	position = vector:new{},
	speed 	 = vector:new{}
}

function body.__init:__index( key )
	if key == 'x' then return self.position[1]
	elseif key == 'y' then return self.position[2]
	elseif key == 'Vx' then return self.speed[1]
	elseif key == 'Vy' then return self.speed[2]
	else return getmetatable(self)[key] end
end

function body.__init:__newindex( key, v )
	if		 key == 'x' then  self.position[1] = v
	elseif key == 'y' then  self.position[2] = v
	elseif key == 'Vx' then self.speed[1] 	 = v
	elseif key == 'Vy' then self.speed[2] 	 = v
	else rawset(self, key, v) end
end

function body:update( dt )
	self.position:add(self.speed * dt)
end

function body:draw()
	if self.changesimage and cheats.image.enabled then
		if cheats.image.painted then graphics.setColor(color(colortimer.time + self.variance))
		else graphics.setColor(255,255,255) end
		if self.stencil then graphics.setStencil(self.stencil) end
		graphics.draw(cheats.image.image, self.position[1] - self.size, self.position[2] - self.size, 0, 2*self.size / cheats.image.image:getWidth(), 2*self.size / cheats.image.image:getHeight())
		if self.stencil then graphics.setStencil() end
		return
	end
	graphics.setColor(color(colortimer.time + self.variance, self.alpha or self.alphafollows and self.alphafollows.var))
	graphics.circle(self.mode, self.position[1], self.position[2], self.size)
end

function body:handleDelete()
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
	p[self.__type] = self.bodies
end

function body:clear()
	cleartable(self.bodies)
end