Basic = lux.object.new {
	alive = true,
	active = true,
	__type = 'Basic'
}

function Basic:kill()
	self.alive = false
end

function Basic:update( dt )

end

function Basic:draw()

end

function Basic:revive()
	if not self.active then self:activate() end
	self.alive = true
	
	return self
end

function Basic:activate()
	self.active = true
end

function Basic:deactivate()
	self.active = false
end