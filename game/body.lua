require 'lux.object'
require 'vector'

body = lux.object.new {
	size = 0,
	__type = 'unnamed body'
}

body.__init = {
	position = vector:new{},
	speed 	 = vector:new{},
	color 	 = {0,0,0,0}
}

function body.__init:__index( key )
	if key == 'x' then return self.position[1]
	elseif key == 'y' then return self.position[2]
	elseif key == 'Vx' then return self.speed[1]
	elseif key == 'Vy' then return self.speed[2]
	else return getmetatable(self)[key] end
end

function body.__init:__newindex( key, v )
	if 	   key == 'x' then  self.position[1] = v
	elseif key == 'y' then  self.position[2] = v
	elseif key == 'Vx' then self.speed[1] 	 = v
	elseif key == 'Vy' then self.speed[2] 	 = v
	else rawset(self, key, v) end
end

function body:update( dt )
	self.position:add(self.speed * dt)
end

function body:draw()
	-- abstract
end

function body:handleDelete()
	-- abstract
end